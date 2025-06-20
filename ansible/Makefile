# Ansible Monitoring Stack Makefile
# Common operations for managing Docker and Monitoring Stack via Ansible

.PHONY: help ping install install-update check syntax lint clean test \
        deploy-monitoring deploy-monitoring-minimal \
        deploy-prometheus deploy-grafana deploy-loki deploy-alertmanager \
        deploy-exporters deploy-collectors monitoring-status monitoring-logs \
        monitoring-stop monitoring-start monitoring-restart monitoring-health \
        monitoring-backup monitoring-update monitoring-check

# Default target
help:
	@echo "Available targets:"
	@echo ""
	@echo "Docker Installation:"
	@echo "  ping                    - Test connectivity to monitoring server"
	@echo "  install                 - Install Docker on the server"
	@echo "  install-update          - Install Docker with system updates"
	@echo "  test                    - Test Docker installation"
	@echo ""
	@echo "Monitoring Stack - Deployment:"
	@echo "  deploy-monitoring       - Deploy all monitoring components (recommended)"
	@echo "  deploy-monitoring-minimal - Deploy minimal stack (Prometheus + Grafana)"
	@echo ""
	@echo "Monitoring Stack - Individual Components:"
	@echo "  deploy-prometheus       - Deploy only Prometheus"
	@echo "  deploy-grafana          - Deploy only Grafana"
	@echo "  deploy-loki             - Deploy only Loki"
	@echo "  deploy-alertmanager     - Deploy only Alertmanager"
	@echo "  deploy-exporters        - Deploy Node Exporter and cAdvisor"
	@echo "  deploy-collectors       - Deploy Promtail"
	@echo "  deploy-promtail-host    - Deploy Promtail on app servers (non-containerized)"
	@echo ""
	@echo "Monitoring Stack - Management:"
	@echo "  monitoring-status       - Check status of all monitoring services"
	@echo "  monitoring-logs         - Show monitoring stack logs"
	@echo "  monitoring-start        - Start all monitoring services"
	@echo "  monitoring-stop         - Stop all monitoring services"
	@echo "  monitoring-restart      - Restart all monitoring services"
	@echo "  monitoring-health       - Run health checks on all services"
	@echo "  monitoring-backup       - Backup monitoring data"
	@echo "  monitoring-update       - Update monitoring components"
	@echo "  monitoring-check        - Run monitoring service check script"
	@echo ""
	@echo "Development:"
	@echo "  check                   - Run playbook in check mode (dry run)"
	@echo "  syntax                  - Check playbook syntax"
	@echo "  lint                    - Lint playbooks with ansible-lint"
	@echo "  clean                   - Clean up temporary files"
	@echo "  help                    - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make deploy-monitoring"
	@echo "  make deploy-monitoring EXTRA_VARS='monitoring_deploy_loki=false'"
	@echo "  make deploy-prometheus EXTRA_VARS='prometheus_retention=90d'"
	@echo "  make monitoring-logs SERVICE=prometheus"
	@echo "  make deploy-promtail-host"

# Test connectivity to monitoring server
ping:
	ansible monitoring_servers -m ping

# Test connectivity to app servers
ping-apps:
	ansible app_servers -m ping

# Test connectivity to all servers
ping-all:
	ansible all -m ping

# Install Docker on the server
install:
	ansible-playbook site.yml

# Install Docker with system updates
install-update:
	ansible-playbook site.yml -e "update_system=true"

# Run in check mode (dry run)
check:
	ansible-playbook site.yml --check

# Check syntax of playbooks
syntax:
	ansible-playbook site.yml --syntax-check
	ansible-playbook playbooks/deploy-monitoring-all.yml --syntax-check
	ansible-playbook playbooks/deploy-monitoring-individual.yml --syntax-check

# Lint playbooks (requires ansible-lint)
lint:
	@which ansible-lint > /dev/null || (echo "ansible-lint not found. Install with: pip install ansible-lint" && exit 1)
	ansible-lint site.yml
	ansible-lint playbooks/deploy-monitoring-all.yml
	ansible-lint playbooks/deploy-monitoring-individual.yml

# Test Docker installation
test:
	ansible monitoring_servers -a "docker --version"
	ansible monitoring_servers -a "docker compose version"

# Deploy all monitoring components (recommended)
deploy-monitoring:
	ansible-playbook playbooks/deploy-monitoring-all.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

# Deploy minimal monitoring stack
deploy-monitoring-minimal:
	ansible-playbook playbooks/deploy-monitoring-all.yml --tags minimal

# Deploy individual components
deploy-prometheus:
	ansible-playbook playbooks/deploy-monitoring-individual.yml --tags common,prometheus

deploy-grafana:
	ansible-playbook playbooks/deploy-monitoring-individual.yml --tags common,grafana

deploy-loki:
	ansible-playbook playbooks/deploy-monitoring-individual.yml --tags common,loki

deploy-alertmanager:
	ansible-playbook playbooks/deploy-monitoring-individual.yml --tags common,alertmanager

deploy-exporters:
	ansible-playbook playbooks/deploy-monitoring-individual.yml --tags common,exporters

deploy-collectors:
	ansible-playbook playbooks/deploy-monitoring-individual.yml --tags common,promtail

# Deploy Promtail directly on app servers (not in containers)
deploy-promtail-host:
	ansible-playbook playbooks/deploy-promtail-host.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

# Monitoring management commands
monitoring-status:
	@if [ -f /opt/monitoring/scripts/check-services.sh ]; then \
		ansible monitoring_servers -a "/opt/monitoring/scripts/check-services.sh" --become; \
	else \
		ansible monitoring_servers -m shell -a "cd /opt/monitoring && for service in prometheus grafana loki alertmanager node-exporter cadvisor promtail; do echo \"Checking \$$service...\"; docker ps | grep \$$service || echo \"\$$service not running\"; done" --become; \
	fi

monitoring-logs:
	@if [ -n "$(SERVICE)" ]; then \
		ansible monitoring_servers -m shell -a "docker logs --tail 100 -f $(SERVICE)" --become; \
	else \
		ansible monitoring_servers -m shell -a "cd /opt/monitoring && for service in prometheus grafana loki alertmanager; do echo \"=== \$$service logs ===\"; docker logs --tail 50 \$$service 2>&1; echo; done" --become; \
	fi

monitoring-start:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring && for dir in prometheus grafana loki alertmanager node-exporter cadvisor promtail; do [ -d \$$dir ] && cd \$$dir && docker compose up -d && cd ..; done" --become

monitoring-stop:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring && for dir in prometheus grafana loki alertmanager node-exporter cadvisor promtail; do [ -d \$$dir ] && cd \$$dir && docker compose down && cd ..; done" --become

monitoring-restart:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring && for dir in prometheus grafana loki alertmanager node-exporter cadvisor promtail; do [ -d \$$dir ] && cd \$$dir && docker compose restart && cd ..; done" --become

monitoring-health:
	@echo "Running health checks on monitoring services..."
	@ansible monitoring_servers -m uri -a "url=http://localhost:9090/-/ready" --become || echo "Prometheus not healthy"
	@ansible monitoring_servers -m uri -a "url=http://localhost:3000/api/health" --become || echo "Grafana not healthy"
	@ansible monitoring_servers -m uri -a "url=http://localhost:3100/ready" --become || echo "Loki not healthy"
	@ansible monitoring_servers -m uri -a "url=http://localhost:9093/-/ready" --become || echo "Alertmanager not healthy"

monitoring-check:
	ansible monitoring_servers -a "/opt/monitoring/scripts/check-services.sh" --become

monitoring-backup:
	ansible monitoring_servers -a "/opt/monitoring/backup-monitoring.sh" --become

monitoring-update:
	ansible-playbook playbooks/deploy-monitoring-all.yml --tags update

# Show monitoring URLs
monitoring-urls:
	@ansible monitoring_servers -m shell -a "echo 'Monitoring Stack URLs:' && echo '=====================' && echo 'Prometheus: http://'\$$(hostname -I | awk '{print \$$1}')':9090' && echo 'Grafana: http://'\$$(hostname -I | awk '{print \$$1}')':3000' && echo 'Loki: http://'\$$(hostname -I | awk '{print \$$1}')':3100' && echo 'Alertmanager: http://'\$$(hostname -I | awk '{print \$$1}')':9093'" --become

# Component-specific operations
restart-prometheus:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring/prometheus && docker compose restart" --become

restart-grafana:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring/grafana && docker compose restart" --become

restart-loki:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring/loki && docker compose restart" --become

restart-alertmanager:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring/alertmanager && docker compose restart" --become

# Clean up temporary files
clean:
	find . -name "*.retry" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete

# Show inventory
inventory:
	ansible-inventory --list

# Show facts for the server
facts:
	ansible monitoring_servers -m setup

# Update system packages only
update-system:
	ansible monitoring_servers -m apt -a "upgrade=dist update_cache=yes autoremove=yes" --become

# Validate monitoring configuration
validate-config:
	@echo "Validating Prometheus configuration..."
	@ansible monitoring_servers -m shell -a "docker run --rm -v /opt/monitoring/prometheus/configs/prometheus.yml:/etc/prometheus/prometheus.yml --entrypoint promtool prom/prometheus:latest check config /etc/prometheus/prometheus.yml" --become
	@echo "Validating Alertmanager configuration..."
	@ansible monitoring_servers -m shell -a "docker run --rm -v /opt/monitoring/alertmanager/configs/alertmanager.yml:/etc/alertmanager/alertmanager.yml --entrypoint amtool prom/alertmanager:latest check-config /etc/alertmanager/alertmanager.yml" --become

# Show disk usage for monitoring
monitoring-disk-usage:
	ansible monitoring_servers -m shell -a "du -sh /opt/monitoring/* | sort -h" --become

# Tail logs for specific service
tail-logs:
	@if [ -z "$(SERVICE)" ]; then echo "Usage: make tail-logs SERVICE=prometheus"; exit 1; fi
	ansible monitoring_servers -m shell -a "docker logs -f --tail 100 $(SERVICE)" --become

# Variables that can be overridden
ANSIBLE_ARGS ?=
EXTRA_VARS ?=
SERVICE ?=

# Advanced deployment examples
deploy-with-ssl:
	ansible-playbook playbooks/deploy-monitoring-all.yml -e "monitoring_ssl_enabled=true monitoring_domain=monitoring.example.com"

deploy-with-auth:
	ansible-playbook playbooks/deploy-monitoring-all.yml -e "monitoring_enable_basic_auth=true grafana_admin_password=$${GRAFANA_PASSWORD}"

# Migration helper
migrate-monitoring:
	@echo "Migrating to new modular monitoring structure..."
	@echo "1. Backing up existing data..."
	@ansible monitoring_servers -m shell -a "[ -d /opt/monitoring ] && tar -czf /opt/monitoring-backup-$$(date +%Y%m%d-%H%M%S).tar.gz /opt/monitoring || echo 'No existing installation found'" --become
	@echo "2. Deploying new structure..."
	@$(MAKE) deploy-monitoring
	@echo "Migration complete. Please verify all services are running."

# Development helpers
test-role:
	@if [ -z "$(ROLE)" ]; then echo "Usage: make test-role ROLE=prometheus"; exit 1; fi
	ansible-playbook -i inventory tests/test-$(ROLE).yml

create-vault:
	ansible-vault create group_vars/all/vault.yml

edit-vault:
	ansible-vault edit group_vars/all/vault.yml

# Show component versions
show-versions:
	@echo "Checking deployed component versions..."
	@ansible monitoring_servers -m shell -a "docker ps --format 'table {{.Names}}\t{{.Image}}' | grep -E 'prometheus|grafana|loki|alertmanager|node-exporter|cadvisor|promtail'" --become

# Useful aliases
status: monitoring-status
logs: monitoring-logs
start: monitoring-start
stop: monitoring-stop
restart: monitoring-restart
backup: monitoring-backup
urls: monitoring-urls
