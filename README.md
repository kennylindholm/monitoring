# Monitoring Stack

A comprehensive monitoring solution using Prometheus, Grafana, Loki, and Alertmanager deployed with Ansible and Docker.

## Overview

This monitoring stack provides:

- **Prometheus** - Metrics collection and storage
- **Grafana** - Visualization and dashboards
- **Loki** - Log aggregation and querying
- **Alertmanager** - Alert routing and management
- **Node Exporter** - System metrics collection
- **cAdvisor** - Container metrics collection
- **Promtail** - Log collection and forwarding

## Quick Start

1. **Setup inventory**:
   ```bash
   cd ansible
   cp inventory.example inventory
   # Edit inventory file with your server details
   ```

2. **Install Docker**:
   ```bash
   make docker-install
   ```

3. **Deploy monitoring stack**:
   ```bash
   make deploy-prometheus
   make deploy-grafana
   make deploy-loki
   make deploy-alertmanager
   ```

4. **Deploy exporters**:
   ```bash
   make deploy-node-exporter
   make deploy-cadvisor
   make deploy-promtail
   ```

## Available Commands

### Deployment
```bash
make deploy-prometheus      # Deploy Prometheus
make deploy-grafana         # Deploy Grafana
make deploy-loki           # Deploy Loki
make deploy-alertmanager   # Deploy Alertmanager
make deploy-node-exporter  # Deploy Node Exporter
make deploy-cadvisor       # Deploy cAdvisor
make deploy-promtail       # Deploy Promtail
```

### Management
```bash
make monitoring-status     # Check service status
make monitoring-logs       # View service logs
make monitoring-start      # Start all services
make monitoring-stop       # Stop all services
make monitoring-restart    # Restart all services
make monitoring-health     # Run health checks
make monitoring-urls       # Show service URLs
```

### Individual Service Management
```bash
make restart-prometheus    # Restart Prometheus
make restart-grafana      # Restart Grafana
make restart-loki         # Restart Loki
make restart-alertmanager # Restart Alertmanager
```

## Updating Components

### Updating Grafana

To update Grafana to a new version:

1. **Edit the version** in `ansible/roles/grafana/vars/main.yml`:
   ```yaml
   grafana_image: "grafana/grafana:12.0.3"  # Change to desired version
   ```

2. **Deploy the update**:
   ```bash
   make deploy-grafana
   ```

The deployment will automatically:
- Pull the new image
- Recreate the container with the new version
- Preserve your data and configuration
- Handle proper container recreation

### Updating Other Components

The same process applies to other components:

#### Prometheus
```yaml
# In ansible/roles/prometheus/vars/main.yml
prometheus_image: "prom/prometheus:v2.45.0"
```
```bash
make deploy-prometheus
```

#### Loki
```yaml
# In ansible/roles/loki/vars/main.yml
loki_image: "grafana/loki:2.9.0"
```
```bash
make deploy-loki
```

#### Alertmanager
```yaml
# In ansible/roles/alertmanager/vars/main.yml
alertmanager_image: "prom/alertmanager:v0.25.0"
```
```bash
make deploy-alertmanager
```

### Update Process Details

When you run a deployment after changing the image version:

1. **Image Pull**: The new image is automatically pulled
2. **Change Detection**: The system detects if the docker-compose file or image has changed
3. **Container Recreation**: If changes are detected, containers are recreated with `--force-recreate`
4. **Health Checks**: Services are verified to be running correctly
5. **Data Preservation**: All persistent data is maintained across updates

### Troubleshooting Updates

If an update fails:

1. **Check logs**:
   ```bash
   make monitoring-logs SERVICE=grafana
   ```

2. **Verify image exists**:
   ```bash
   docker pull grafana/grafana:12.0.3
   ```

3. **Manual container recreation**:
   ```bash
   # Stop current container
   make monitoring-stop

   # Pull new images and recreate
   ansible monitoring_servers -m shell -a "cd /opt/monitoring/grafana && docker compose pull && docker compose up -d --force-recreate" --become
   ```

4. **Rollback if needed**:
   ```bash
   # Change back to previous version in vars/main.yml
   make deploy-grafana
   ```

### Best Practices for Updates

1. **Backup First**: Always backup your data before major updates
   ```bash
   make monitoring-backup
   ```

2. **Test in Staging**: Test updates in a non-production environment first

3. **Read Release Notes**: Check component release notes for breaking changes

4. **Monitor After Update**: Watch logs and metrics after updating
   ```bash
   make monitoring-health
   make monitoring-logs
   ```

5. **Update Dependencies**: Update related components if needed

## Configuration

### Default Ports
- Prometheus: 9090
- Grafana: 3000
- Loki: 3100
- Alertmanager: 9093
- Node Exporter: 9100
- cAdvisor: 8080
- Promtail: 9080

### Default Credentials
- **Grafana**: admin / admin123 (change in `ansible/roles/grafana/vars/main.yml`)

### Data Persistence
All data is stored in `/opt/monitoring/` on the target servers:
- Prometheus data: `/opt/monitoring/prometheus/data`
- Grafana data: `/opt/monitoring/grafana/data`
- Loki data: `/opt/monitoring/loki/data`
- Alertmanager data: `/opt/monitoring/alertmanager/data`

## Security Considerations

1. **Change default passwords** in variable files
2. **Use Ansible Vault** for sensitive data:
   ```bash
   make create-vault
   ```
3. **Configure firewall rules** appropriately
4. **Enable SSL/TLS** for production deployments

## Monitoring URLs

After deployment, access your monitoring stack:

- **Grafana**: http://your-server:3000
- **Prometheus**: http://your-server:9090
- **Alertmanager**: http://your-server:9093
- **Loki**: http://your-server:3100

## Backup and Recovery

### Create Backup
```bash
make monitoring-backup
```

### Manual Backup
```bash
# Backup all monitoring data
ansible monitoring_servers -m archive -a "path=/opt/monitoring dest=/tmp/monitoring-backup-$(date +%Y%m%d).tar.gz" --become
```

## Troubleshooting

### Common Issues

1. **Services not starting**:
   ```bash
   make monitoring-status
   make monitoring-logs
   ```

2. **Port conflicts**:
   ```bash
   # Check what's using the port
   ansible monitoring_servers -m shell -a "netstat -tulpn | grep :3000" --become
   ```

3. **Permission issues**:
   ```bash
   # Fix permissions
   ansible monitoring_servers -m shell -a "chown -R 472:0 /opt/monitoring/grafana/data" --become
   ```

4. **Disk space**:
   ```bash
   make monitoring-disk-usage
   ```

### Getting Help

1. Check logs: `make monitoring-logs`
2. Verify configuration: `make validate-config`
3. Check connectivity: `make ping`
4. Review service status: `make monitoring-status`

## Development

### Project Structure
```
monitoring/
├── ansible/
│   ├── roles/           # Ansible roles for each component
│   ├── playbooks/       # Deployment playbooks
│   ├── inventory        # Server inventory
│   └── Makefile        # Automation commands
└── README.md           # This file
```

### Adding New Components

1. Create new role in `ansible/roles/`
2. Add deployment playbook in `ansible/playbooks/`
3. Update Makefile with new commands
4. Test deployment and integration

## License

This project is licensed under the MIT License.
