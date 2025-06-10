#!/bin/bash

# Monitoring Stack Deployment Script
# Fixes locale and environment issues

set -e

# Set proper locale and environment
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export LANGUAGE=C.UTF-8

# Change to ansible directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Function to show help
show_help() {
    echo "Monitoring Stack Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy-monitoring    Deploy complete monitoring stack"
    echo "  install-docker      Install Docker only"
    echo "  deploy-all          Install Docker + Deploy monitoring"
    echo "  check               Run in check mode (dry run)"
    echo "  status              Check monitoring stack status"
    echo "  restart             Restart monitoring stack"
    echo "  logs                Show monitoring stack logs"
    echo "  prometheus-logs     Show Prometheus logs specifically"
    echo "  loki-logs           Show Loki logs specifically"
    echo "  help                Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 deploy-monitoring"
    echo "  $0 deploy-all"
    echo "  $0 check"
}

# Function to run ansible-playbook with proper environment
run_ansible() {
    local playbook="$1"
    local extra_args="${2:-}"
    
    echo "Running: ansible-playbook $playbook $extra_args"
    echo "Environment: LC_ALL=$LC_ALL"
    echo ""
    
    ansible-playbook "$playbook" $extra_args
}

# Main command handling
case "${1:-help}" in
    deploy-monitoring)
        echo "Deploying monitoring stack (Grafana, Prometheus, Loki, Alertmanager)..."
        run_ansible "playbooks/deploy-monitoring.yml"
        ;;
    install-docker)
        echo "Installing Docker..."
        run_ansible "playbooks/install-docker.yml"
        ;;
    deploy-all)
        echo "Installing Docker and deploying monitoring stack..."
        run_ansible "site.yml"
        ;;
    check)
        echo "Running in check mode (dry run)..."
        run_ansible "playbooks/deploy-monitoring.yml" "--check"
        ;;
    check-docker)
        echo "Checking Docker installation..."
        run_ansible "playbooks/install-docker.yml" "--check"
        ;;
    ping)
        echo "Testing connectivity to servers..."
        ansible debian_servers -m ping
        ;;
    status)
        echo "Checking monitoring stack status..."
        echo "Running: docker compose ps in /opt/monitoring/"
        ansible debian_servers -a "docker compose -f /opt/monitoring/docker-compose.yml ps" --become 2>/dev/null || echo "Monitoring stack not deployed yet"
        ;;
    update-config)
        echo "Updating monitoring configuration..."
        run_ansible "playbooks/deploy-monitoring.yml" "--tags config"
        ;;
    restart-prometheus)
        echo "Restarting Prometheus service..."
        ansible debian_servers -a "docker compose -f /opt/monitoring/docker-compose.yml restart prometheus" --become
        ;;
    restart)
        echo "Restarting monitoring stack..."
        ansible debian_servers -a "docker compose -f /opt/monitoring/docker-compose.yml restart" --become
        ;;
    logs)
        echo "Showing monitoring stack logs..."
        ansible debian_servers -a "docker compose -f /opt/monitoring/docker-compose.yml logs --tail=50" --become
        ;;
    prometheus-logs)
        echo "Showing Prometheus logs..."
        ansible debian_servers -a "docker compose -f /opt/monitoring/docker-compose.yml logs prometheus --tail=20" --become
        ;;
    loki-logs)
        echo "Showing Loki logs..."
        ansible debian_servers -a "docker compose -f /opt/monitoring/docker-compose.yml logs loki --tail=20" --become
        ;;
    validate-config)
        echo "Validating Prometheus configuration..."
        ansible debian_servers -a "docker run --rm -v /opt/monitoring/configs/prometheus.yml:/etc/prometheus/prometheus.yml -v /opt/monitoring/configs/alert-rules.yml:/etc/prometheus/alert-rules.yml --entrypoint promtool prom/prometheus:latest check config /etc/prometheus/prometheus.yml" --become
        ;;
    fix-permissions)
        echo "Fixing data directory permissions..."
        ansible debian_servers -a "chown -R 65534:65534 /opt/monitoring/prometheus/data" --become
        ansible debian_servers -a "chown -R 472:0 /opt/monitoring/grafana/data" --become
        ansible debian_servers -a "chown -R 10001:10001 /opt/monitoring/loki/data" --become
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac

echo ""
echo "Deployment script completed!"