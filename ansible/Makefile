# Ansible Monitoring Stack Makefile
# Common operations for managing Docker and Monitoring Stack via Ansible

.PHONY: help ping docker-status \
        deploy-prometheus deploy-grafana deploy-loki deploy-alertmanager \
        deploy-cadvisor deploy-grafana-alloy deploy-monitoring-scripts \
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
	@echo "  deploy-grafana          - Deploy Grafana"
	@echo "  deploy-loki             - Deploy Loki"
	@echo "  deploy-prometheus       - Deploy Prometheus"
	@echo "  deploy-alertmanager     - Deploy Alertmanager"
	  deploy-grafana-alloy    - Deploy Grafana Alloy (unified metrics and logs)"
	@echo "  deploy-cadvisor         - Deploy cAdvisor on docker_hosts"
	@echo "  deploy-monitoring-scripts - Deploy monitoring scripts (backup, service status, etc.)"
	  deploy-full-stack       - Deploy complete monitoring stack with Grafana Alloy"
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
	  restart-grafana-alloy   - Restart Grafana Alloy service"
	@echo "  tail-logs               - Tail logs for specific service (requires SERVICE=name)"
	@echo ""
	@echo "System & Configuration:"
	@echo "  inventory               - Show Ansible inventory"
	@echo "  facts                   - Show facts for monitoring servers"
	@echo "  validate-config         - Validate monitoring configuration"
	@echo "  show-versions           - Show deployed component versions"
	  check-grafana-alloy     - Check Grafana Alloy status on client hosts"
	@echo ""
	@echo "Security & Vault:"
	@echo "  create-vault            - Create new Ansible vault file"
	@echo "  edit-vault              - Edit existing Ansible vault file"


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
deploy-cadvisor:
	ansible-playbook playbooks/deploy-cadvisor.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

# Deploy Grafana Alloy (unified metrics and logs collection)
deploy-grafana-alloy:
	ansible-playbook playbooks/deploy-grafana-alloy.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

# Deploy monitoring scripts (backup, service status)
deploy-monitoring-scripts:
	ansible-playbook playbooks/deploy-monitoring-scripts.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

# Monitoring management commands
monitoring-status:
	@if [ -f /opt/monitoring/scripts/check-services.sh ]; then \
		ansible monitoring_servers -a "/opt/monitoring/scripts/check-services.sh" --become; \
	else \
		ansible monitoring_servers -m shell -a "cd /opt/monitoring && for service in prometheus grafana loki alertmanager cadvisor; do echo \"Checking \$$service...\"; docker ps | grep \$$service || echo \"\$$service not running\"; done" --become; \
	fi
	@echo "Checking Grafana Alloy on client hosts..."
	@ansible client_hosts -m shell -a "systemctl is-active alloy || echo 'alloy not running'" --become || true

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
	@echo "Checking Grafana Alloy health on client hosts..."
	@ansible client_hosts -m uri -a "url=http://localhost:12345/-/ready" --become || echo "Grafana Alloy not healthy"

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
	ansible-playbook playbooks/deploy-grafana-alloy.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	ansible-playbook playbooks/deploy-monitoring-scripts.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")


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

restart-grafana-alloy:
	ansible client_hosts -m shell -a "systemctl restart alloy" --become



# Show inventory
inventory:
	ansible-inventory --list --ask-vault-pass

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



create-vault:
	ansible-vault create group_vars/all/vault.yml

edit-vault:
	ansible-vault edit group_vars/all/vault.yml

# Show component versions
show-versions:
	@echo "=== Docker Container Versions ==="
	@ansible monitoring_servers -m shell -a "docker ps" --become || true
	@echo ""
	@echo "=== Grafana Alloy Status ==="
	@ansible client_hosts -m shell -a "systemctl is-active alloy || echo 'inactive'" --become || true

# Check client hosts exporters (legacy - use check-grafana-alloy for new setup)
check-exporters:
	@echo "NOTE: Node Exporter has been replaced by Grafana Alloy"
	@echo "Use 'make check-grafana-alloy' instead"

# Check Grafana Alloy on client hosts
check-grafana-alloy:
	@echo "Checking Grafana Alloy on client hosts..."
	@ansible client_hosts -m uri -a "url=http://localhost:12345/-/ready" --become || echo "Grafana Alloy not accessible on some hosts"
	@ansible client_hosts -m uri -a "url=http://localhost:12345/metrics" --become || echo "Grafana Alloy metrics not accessible on some hosts"

# Deploy complete monitoring stack with Grafana Alloy
deploy-full-stack:
	@echo "Deploying complete monitoring stack with Grafana Alloy..."
	@echo "=============================================="
	@echo "1. Deploying core monitoring services..."
	ansible-playbook playbooks/deploy-prometheus.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	ansible-playbook playbooks/deploy-grafana.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	ansible-playbook playbooks/deploy-loki.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	ansible-playbook playbooks/deploy-alertmanager.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	ansible-playbook playbooks/deploy-cadvisor.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	@echo "=============================================="
	@echo "2. Deploying Grafana Alloy (unified metrics and logs collection)..."
	ansible-playbook playbooks/deploy-grafana-alloy.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	@echo "=============================================="
	@echo "3. Deploying monitoring scripts..."
	ansible-playbook playbooks/deploy-monitoring-scripts.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")
	@echo "=============================================="
	@echo "Full monitoring stack deployment complete!"
	@echo ""
	@echo "Access URLs:"
	@ansible monitoring_servers -m shell -a "echo 'Prometheus: http://'\$$(hostname -I | awk '{print \$$1}')':9090'" --become
	@ansible monitoring_servers -m shell -a "echo 'Grafana: http://'\$$(hostname -I | awk '{print \$$1}')':3000'" --become
	@ansible monitoring_servers -m shell -a "echo 'Loki: http://'\$$(hostname -I | awk '{print \$$1}')':3100'" --become
	@ansible monitoring_servers -m shell -a "echo 'Alertmanager: http://'\$$(hostname -I | awk '{print \$$1}')':9093'" --become
	@echo ""
	@echo "Grafana Alloy Web UIs:"
	@ansible client_hosts -m shell -a "echo 'Grafana Alloy: http://'\$$(hostname -I | awk '{print \$$1}')':12345'" --become
	@echo "=============================================="

# Variables that can be overridden
ANSIBLE_ARGS ?=
EXTRA_VARS ?=
SERVICE ?=
