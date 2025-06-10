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
    echo "  ping                Test connectivity"
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
        ansible debian_servers -a "/opt/monitoring/manage-stack.sh status" --become || echo "Monitoring stack not deployed yet"
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