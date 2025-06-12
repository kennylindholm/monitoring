# Makefile Usage Guide for Monitoring Stack

This guide provides examples and best practices for using the Makefile with the split monitoring roles on a single server setup.

## Prerequisites

Before using the Makefile, ensure you have:

- Ansible installed (`pip install ansible`)
- An inventory file configured with your target server
- SSH access to the server
- Docker installed on the server (or use `make install`)

## Basic Commands

### Initial Setup

```bash
# Test connectivity to the monitoring server
make ping

# Install Docker on the server
make install

# Install Docker with system updates
make install-update

# Verify Docker installation
make test
```

### Full Stack Deployment

```bash
# Deploy complete monitoring stack (recommended)
make deploy-monitoring

# Deploy minimal stack (Prometheus + Grafana only)
make deploy-monitoring-minimal

# Deploy with custom components disabled
make deploy-monitoring EXTRA_VARS='monitoring_deploy_loki=false monitoring_deploy_promtail=false'
```

## Individual Component Deployment

### Deploy Single Components

```bash
# Deploy only Prometheus
make deploy-prometheus

# Deploy only Grafana
make deploy-grafana

# Deploy only Loki
make deploy-loki

# Deploy only Alertmanager
make deploy-alertmanager

# Deploy exporters (Node Exporter + cAdvisor)
make deploy-exporters

# Deploy log collectors (Promtail)
make deploy-collectors
```

### Custom Deployment Options

```bash
# Deploy with custom variables
make deploy-monitoring EXTRA_VARS='prometheus_retention=90d grafana_admin_password=MySecurePass123'

# Deploy with specific Grafana plugins
make deploy-monitoring EXTRA_VARS='meta_grafana_plugins=["grafana-clock-panel","grafana-piechart-panel"]'

# Deploy with custom resource limits
make deploy-monitoring EXTRA_VARS='monitoring_resource_limits={"prometheus":{"memory":"2Gi","cpu":"1000m"}}'
```

## Management Commands

### Service Status and Health

```bash
# Check status of all monitoring services
make monitoring-status

# Run comprehensive health checks
make monitoring-health

# Check service status using the script
make monitoring-check

# Show monitoring URLs
make monitoring-urls
```

### Service Control

```bash
# Start all monitoring services
make monitoring-start

# Stop all monitoring services
make monitoring-stop

# Restart all monitoring services
make monitoring-restart

# Restart specific component
make restart-prometheus
make restart-grafana
make restart-loki
make restart-alertmanager
```

### Logs and Debugging

```bash
# Show logs for all services
make monitoring-logs

# Show logs for specific service
make monitoring-logs SERVICE=prometheus

# Tail logs for a specific service
make tail-logs SERVICE=grafana

# Check disk usage
make monitoring-disk-usage
```

### Backup and Updates

```bash
# Backup monitoring data
make monitoring-backup

# Update all monitoring components
make monitoring-update

# Show deployed component versions
make show-versions
```

## Advanced Usage

### Security Configuration

```bash
# Deploy with SSL enabled
make deploy-with-ssl

# Deploy with authentication
make deploy-with-auth GRAFANA_PASSWORD=SuperSecurePassword

# Custom security settings
make deploy-monitoring EXTRA_VARS='monitoring_ssl_enabled=true monitoring_enable_basic_auth=true monitoring_domain=monitoring.example.com'
```

### Resource Configuration

```bash
# Deploy with custom resource limits
make deploy-monitoring EXTRA_VARS='monitoring_resource_limits={"prometheus":{"memory":"4Gi","cpu":"2000m"},"grafana":{"memory":"1Gi","cpu":"1000m"}}'

# Deploy with custom retention settings
make deploy-monitoring EXTRA_VARS='prometheus_retention=90d loki_retention_period=2160h'
```

### Network Configuration

```bash
# Deploy with custom network settings
make deploy-monitoring EXTRA_VARS='monitoring_network_name=custom-monitoring monitoring_network_subnet=172.30.0.0/16'
```

## Development and Testing

### Syntax and Validation

```bash
# Check playbook syntax
make syntax

# Lint playbooks (requires ansible-lint)
make lint

# Run in check mode (dry run)
make check

# Validate monitoring configurations
make validate-config
```

### Testing Individual Roles

```bash
# Test specific role
make test-role ROLE=prometheus

# Show server facts
make facts

# Show inventory
make inventory
```

### Vault Management

```bash
# Create encrypted vault file
make create-vault

# Edit vault file
make edit-vault

# Use vault in deployment
make deploy-monitoring ANSIBLE_ARGS='--ask-vault-pass'
```

## Migration

### From Old monitoring-stack Role

```bash
# Automated migration with backup
make migrate-monitoring

# Manual migration steps
# 1. Backup existing data
ansible monitoring_servers -m shell -a "tar -czf /opt/monitoring-backup.tar.gz /opt/monitoring" --become

# 2. Stop old stack
ansible monitoring_servers -m shell -a "cd /opt/monitoring && docker compose down" --become

# 3. Deploy new structure
make deploy-monitoring

# 4. Verify data persistence
make monitoring-status
```

## Troubleshooting

### Common Issues

```bash
# Check Docker installation
make test

# Show server facts
make facts

# Check inventory
make inventory

# Clean up temporary files
make clean

# Validate configurations
make validate-config
```

### Service-Specific Debugging

```bash
# Check Prometheus targets
ansible monitoring_servers -m uri -a "url=http://localhost:9090/api/v1/targets" --become | jq

# Check Grafana datasources
ansible monitoring_servers -m uri -a "url=http://localhost:3000/api/datasources user=admin password=admin123 force_basic_auth=yes" --become

# Check Loki labels
ansible monitoring_servers -m uri -a "url=http://localhost:3100/loki/api/v1/labels" --become

# Tail specific service logs
make tail-logs SERVICE=prometheus
```

## Common Deployment Scenarios

### Production Deployment

```bash
# Full production deployment with all security features
make deploy-monitoring EXTRA_VARS='
  environment=production
  monitoring_enable_backup=true
  monitoring_backup_retention_days=30
  prometheus_retention=90d
  loki_retention_period=2160h
  monitoring_ssl_enabled=true
  monitoring_enable_basic_auth=true
  alertmanager_smtp_enabled=true
  alertmanager_smtp_server=smtp.company.com:587
  alertmanager_smtp_from=monitoring@company.com
  alertmanager_receiver_email=ops-team@company.com
  grafana_admin_password={{ vault_grafana_password }}
'
```

### Development Environment

```bash
# Minimal development setup
make deploy-monitoring EXTRA_VARS='
  environment=development
  monitoring_deploy_alertmanager=false
  monitoring_deploy_promtail=false
  monitoring_enable_backup=false
  prometheus_retention=7d
  loki_retention_period=168h
'
```

### Monitoring Docker Containers

```bash
# Deploy with focus on container monitoring
make deploy-monitoring EXTRA_VARS='
  monitoring_deploy_cadvisor=true
  monitoring_deploy_node_exporter=true
  cadvisor_enable_metrics=["cpu","memory","network","disk"]
'
```

## Quick Reference

### Essential Commands

| Command                   | Description           |
| ------------------------- | --------------------- |
| `make deploy-monitoring`  | Deploy complete stack |
| `make monitoring-status`  | Check service status  |
| `make monitoring-logs`    | View logs             |
| `make monitoring-restart` | Restart all services  |
| `make monitoring-backup`  | Backup data           |
| `make monitoring-urls`    | Show access URLs      |

### Component-Specific Commands

| Command                          | Description            |
| -------------------------------- | ---------------------- |
| `make deploy-prometheus`         | Deploy Prometheus only |
| `make deploy-grafana`            | Deploy Grafana only    |
| `make restart-prometheus`        | Restart Prometheus     |
| `make tail-logs SERVICE=grafana` | Tail Grafana logs      |

### Useful Aliases

The Makefile includes short aliases for common commands:

- `make status` → `make monitoring-status`
- `make logs` → `make monitoring-logs`
- `make start` → `make monitoring-start`
- `make stop` → `make monitoring-stop`
- `make restart` → `make monitoring-restart`
- `make backup` → `make monitoring-backup`
- `make urls` → `make monitoring-urls`

## Environment Variables

You can set these environment variables to customize behavior:

```bash
# Set custom Ansible arguments
export ANSIBLE_ARGS="--verbose --diff"

# Set default extra variables
export EXTRA_VARS="monitoring_base_dir=/opt/custom-monitoring"

# Run with environment variables
make deploy-monitoring
```

## Tips and Best Practices

1. **Always test in check mode first:**

   ```bash
   make check
   ```

2. **Use version tags for production:**

   ```bash
   make deploy-monitoring EXTRA_VARS='prometheus_image=prom/prometheus:v2.45.0'
   ```

3. **Enable backup before major changes:**

   ```bash
   make monitoring-backup
   ```

4. **Monitor disk usage regularly:**

   ```bash
   make monitoring-disk-usage
   ```

5. **Use vault for sensitive data:**

   ```bash
   make deploy-monitoring ANSIBLE_ARGS='--vault-id @prompt'
   ```

6. **Document custom configurations:**

   ```bash
   make deploy-monitoring EXTRA_VARS='@custom-config.yml'
   ```

7. **Check service health after deployment:**

   ```bash
   make monitoring-health
   make monitoring-check
   ```

8. **Review logs if services fail:**
   ```bash
   make monitoring-logs SERVICE=prometheus
   ```

## Maintenance

### Regular Tasks

```bash
# Daily: Check service status
make monitoring-status

# Weekly: Check disk usage
make monitoring-disk-usage

# Monthly: Backup data
make monitoring-backup

# Quarterly: Update components
make monitoring-update
```

### Emergency Procedures

```bash
# If services are down
make monitoring-restart

# If disk is full
make monitoring-disk-usage
# Then clean up old data or increase retention

# If configuration is broken
make validate-config
# Fix issues and redeploy

# Complete reset (with data loss)
make monitoring-stop
# Remove data directories
make deploy-monitoring
```
