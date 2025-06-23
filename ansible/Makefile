# Ansible Monitoring Stack Makefile
# Common operations for managing Docker and Monitoring Stack via Ansible

.PHONY: help ping install check syntax lint clean docker-status \
        deploy-prometheus deploy-grafana deploy-loki deploy-alertmanager \
        deploy-node-exporter deploy-cadvisor deploy-promtail \
        monitoring-status monitoring-logs \
        monitoring-stop monitoring-start monitoring-restart monitoring-health \
        monitoring-backup monitoring-update monitoring-check

# Default target
help:
	@echo "Available targets:"
	@echo ""
	@echo "Connectivity & Testing:"
	@echo "  ping                    - Test connectivity to all hosts"
	@echo ""
	@echo "Docker Installation:"
	@echo "  docker-install          - Install Docker and Docker Compose"
	@echo "  docker-status           - Test Docker installation"
	@echo ""
	@echo "Monitoring Stack:"
	@echo "  deploy-grafana          - Deploy only Grafana"
	@echo "  deploy-loki             - Deploy only Loki"
	@echo "  deploy-prometheus       - Deploy only Prometheus"
	@echo "  deploy-alertmanager     - Deploy only Alertmanager"
	@echo "  deploy-promtail         - Deploy Promtail on client hosts"
	@echo "  deploy-node-exporter    - Deploy Node Exporter on client hosts"
	@echo "  deploy-cadvisor         - Deploy cAdvisor on client hosts"
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
	@echo "  monitoring-urls         - Show monitoring URLs"
	@echo "  monitoring-disk-usage   - Show disk usage for monitoring"
	@echo ""
	@echo "Individual Component Management:"
	@echo "  restart-prometheus      - Restart Prometheus service"
	@echo "  restart-grafana         - Restart Grafana service"
	@echo "  restart-loki            - Restart Loki service"
	@echo "  restart-alertmanager    - Restart Alertmanager service"
	@echo "  restart-cadvisor        - Restart cAdvisor service"
	@echo "  tail-logs               - Tail logs for specific service (requires SERVICE=name)"
	@echo ""
	@echo "System & Configuration:"
	@echo "  inventory               - Show Ansible inventory"
	@echo "  facts                   - Show facts for monitoring servers"
	@echo "  validate-config         - Validate monitoring configuration"
	@echo "  show-versions           - Show deployed component versions"
	@echo ""
	@echo "Development & Testing:"
	@echo "  check                   - Run playbook in check mode (dry run)"
	@echo "  syntax                  - Check playbook syntax"
	@echo "  lint                    - Lint playbooks with ansible-lint"
	@echo "  test-role               - Test specific role (requires ROLE=name)"
	@echo "  clean                   - Clean up temporary files"
	@echo ""
	@echo "Security & Vault:"
	@echo "  create-vault            - Create new Ansible vault file"
	@echo "  edit-vault              - Edit existing Ansible vault file"
	@echo ""
	@echo "Convenient Aliases:"
	@echo "  status                  - Alias for monitoring-status"
	@echo "  logs                    - Alias for monitoring-logs"
	@echo "  start                   - Alias for monitoring-start"
	@echo "  stop                    - Alias for monitoring-stop"
	@echo "  restart                 - Alias for monitoring-restart"
	@echo "  backup                  - Alias for monitoring-backup"
	@echo "  urls                    - Alias for monitoring-urls"
	@echo "  deploy                  - Alias for deploy-all"
	@echo "  help                    - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make deploy-all"
	@echo "  make deploy-prometheus EXTRA_VARS='prometheus_retention=90d'"
	@echo "  make deploy-grafana"
	@echo "  make monitoring-logs SERVICE=prometheus"
	@echo "  make tail-logs SERVICE=grafana"
	@echo "  make deploy-promtail"
	@echo "  make test-role ROLE=prometheus"

# Test connectivity to all servers
ping:
	ansible all -m ping

# Install Docker on servers
docker-install:
	ansible-playbook playbooks/install-docker.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

# Test Docker installation
docker-status:
	ansible monitoring_servers -a "docker --version"
	ansible monitoring_servers -a "docker compose version"

# Run in check mode (dry run)
check:
	ansible-playbook site.yml --check

# Check syntax of playbooks
syntax:
	ansible-playbook site.yml --syntax-check
	ansible-playbook playbooks/deploy-prometheus.yml --syntax-check
	ansible-playbook playbooks/deploy-grafana.yml --syntax-check
	ansible-playbook playbooks/deploy-loki.yml --syntax-check
	ansible-playbook playbooks/deploy-alertmanager.yml --syntax-check
	ansible-playbook playbooks/deploy-node-exporter.yml --syntax-check
	ansible-playbook playbooks/deploy-cadvisor.yml --syntax-check
	ansible-playbook playbooks/deploy-promtail.yml --syntax-check
	ansible-playbook playbooks/install-docker.yml --syntax-check

# Lint playbooks (requires ansible-lint)
lint:
	@which ansible-lint > /dev/null || (echo "ansible-lint not found. Install with: pip install ansible-lint" && exit 1)
	ansible-lint site.yml
	ansible-lint playbooks/deploy-prometheus.yml
	ansible-lint playbooks/deploy-grafana.yml
	ansible-lint playbooks/deploy-loki.yml
	ansible-lint playbooks/deploy-alertmanager.yml
	ansible-lint playbooks/deploy-node-exporter.yml
	ansible-lint playbooks/deploy-cadvisor.yml
	ansible-lint playbooks/deploy-promtail.yml
	ansible-lint playbooks/install-docker.yml

# Deploy individual components using dedicated playbooks
deploy-prometheus:
	ansible-playbook playbooks/deploy-prometheus.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

deploy-grafana:
	ansible-playbook playbooks/deploy-grafana.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

deploy-loki:
	ansible-playbook playbooks/deploy-loki.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

deploy-alertmanager:
	ansible-playbook playbooks/deploy-alertmanager.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

# Deploy exporters using dedicated playbooks
deploy-node-exporter:
	ansible-playbook playbooks/deploy-node-exporter.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

deploy-cadvisor:
	ansible-playbook playbooks/deploy-cadvisor.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

# Deploy Promtail on client hosts
deploy-promtail:
	ansible-playbook playbooks/deploy-promtail.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

# Monitoring management commands
monitoring-status:
	@if [ -f /opt/monitoring/scripts/check-services.sh ]; then \
		ansible monitoring_servers -a "/opt/monitoring/scripts/check-services.sh" --become; \
	else \
		ansible monitoring_servers -m shell -a "cd /opt/monitoring && for service in prometheus grafana loki alertmanager cadvisor; do echo \"Checking \$$service...\"; docker ps | grep \$$service || echo \"\$$service not running\"; done" --become; \
	fi

monitoring-logs:
	@if [ -n "$(SERVICE)" ]; then \
		ansible monitoring_servers -m shell -a "docker logs --tail 100 -f $(SERVICE)" --become; \
	else \
		ansible monitoring_servers -m shell -a "cd /opt/monitoring && for service in prometheus grafana loki alertmanager cadvisor; do echo \"=== \$$service logs ===\"; docker logs --tail 50 \$$service 2>&1; echo; done" --become; \
	fi

monitoring-start:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring && for dir in prometheus grafana loki alertmanager cadvisor; do [ -d \$$dir ] && cd \$$dir && docker compose up -d && cd ..; done" --become

monitoring-stop:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring && for dir in prometheus grafana loki alertmanager cadvisor; do [ -d \$$dir ] && cd \$$dir && docker compose down && cd ..; done" --become

monitoring-restart:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring && for dir in prometheus grafana loki alertmanager cadvisor; do [ -d \$$dir ] && cd \$$dir && docker compose restart && cd ..; done" --become

monitoring-health:
	@echo "Running health checks on monitoring services..."
	@ansible monitoring_servers -m uri -a "url=http://localhost:9090/-/ready" --become || echo "Prometheus not healthy"
	@ansible monitoring_servers -m uri -a "url=http://localhost:3000/api/health" --become || echo "Grafana not healthy"
	@ansible monitoring_servers -m uri -a "url=http://localhost:3100/ready" --become || echo "Loki not healthy"
	@ansible monitoring_servers -m uri -a "url=http://localhost:9093/-/ready" --become || echo "Alertmanager not healthy"
	@ansible monitoring_servers -m uri -a "url=http://localhost:8080/healthz" --become || echo "cAdvisor not healthy"

monitoring-check:
	ansible monitoring_servers -a "/opt/monitoring/scripts/check-services.sh" --become

monitoring-backup:
	ansible monitoring_servers -a "/opt/monitoring/backup-monitoring.sh" --become

monitoring-update:
	ansible-playbook playbooks/deploy-prometheus.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	ansible-playbook playbooks/deploy-grafana.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	ansible-playbook playbooks/deploy-loki.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	ansible-playbook playbooks/deploy-alertmanager.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	ansible-playbook playbooks/deploy-cadvisor.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	ansible-playbook playbooks/deploy-node-exporter.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	ansible-playbook playbooks/deploy-promtail.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

# Show monitoring URLs
monitoring-urls:
	@ansible monitoring_servers -m shell -a "echo 'Monitoring Stack URLs:' && echo '=====================' && echo 'Prometheus: http://'\$$(hostname -I | awk '{print \$$1}')':9090' && echo 'Grafana: http://'\$$(hostname -I | awk '{print \$$1}')':3000' && echo 'Loki: http://'\$$(hostname -I | awk '{print \$$1}')':3100' && echo 'Alertmanager: http://'\$$(hostname -I | awk '{print \$$1}')':9093' && echo 'cAdvisor: http://'\$$(hostname -I | awk '{print \$$1}')':8080'" --become

# Component-specific operations
restart-prometheus:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring/prometheus && docker compose restart" --become

restart-grafana:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring/grafana && docker compose restart" --become

restart-loki:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring/loki && docker compose restart" --become

restart-alertmanager:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring/alertmanager && docker compose restart" --become

restart-cadvisor:
	ansible monitoring_servers -m shell -a "cd /opt/monitoring/cadvisor && docker compose restart" --become

# Clean up temporary files
clean:
	find . -name "*.retry" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete

# Show inventory
inventory:
	ansible-inventory --list

# Show facts for monitoring servers
facts:
	ansible monitoring_servers -m setup

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

# Development helpers
test-role:
	@if [ -z "$(ROLE)" ]; then echo "Usage: make test-role ROLE=prometheus"; exit 1; fi
	@if [ ! -f "playbooks/deploy-$(ROLE).yml" ]; then echo "Playbook deploy-$(ROLE).yml does not exist"; exit 1; fi
	@echo "Testing role: $(ROLE)"
	ansible-playbook --check playbooks/deploy-$(ROLE).yml $(ANSIBLE_ARGS)

create-vault:
	ansible-vault create group_vars/all/vault.yml

edit-vault:
	ansible-vault edit group_vars/all/vault.yml

# Show component versions
show-versions:
	@echo "Checking deployed component versions..."
	@ansible monitoring_servers -m shell -a "docker ps --format 'table {{.Names}}\t{{.Image}}' | grep -E 'prometheus|grafana|loki|alertmanager|cadvisor'" --become
	@echo "Checking Promtail versions on client hosts..."
	@ansible client_hosts -m shell -a "systemctl status promtail | grep Active" --become

# Check client hosts exporters
check-exporters:
	@echo "Checking Node Exporter on client hosts..."
	@ansible client_hosts -m uri -a "url=http://localhost:9100/metrics" --become || echo "Node Exporter not accessible on some hosts"
	@echo "Checking Promtail on client hosts..."
	@ansible client_hosts -m uri -a "url=http://localhost:9080/targets" --become || echo "Promtail not accessible on some hosts"

# Variables that can be overridden
ANSIBLE_ARGS ?=
EXTRA_VARS ?=
SERVICE ?=
ROLE ?=
