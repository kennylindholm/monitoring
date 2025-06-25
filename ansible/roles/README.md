# Monitoring Stack Ansible Roles

This directory contains individual Ansible roles for deploying a complete monitoring stack. The roles are modular components that provide flexibility and maintainability.

## Available Roles

### Core Components

- **prometheus** - Time-series metrics database and monitoring system (Port: 9090)
- **grafana** - Visualization and dashboarding platform (Port: 3000)
- **loki** - Log aggregation system (Port: 3100)
- **alertmanager** - Alert routing and management (Port: 9093)

### Exporters

- **node-exporter** - System and hardware metrics exporter (Port: 9100)
- **cadvisor** - Container metrics exporter (Port: 8080)

### Collectors

- **promtail** - Log collector and forwarder for Loki (Port: 9080)

### Supporting Roles

- **monitoring-common** - Common prerequisites and shared configuration

## Role Structure

Each role follows the standard Ansible role structure:

```
role-name/
├── tasks/
│   └── main.yml         # Main tasks for the role
├── handlers/
│   └── main.yml         # Handler definitions
├── templates/
│   └── *.j2             # Jinja2 templates
├── vars/
│   └── main.yml         # Role variables
├── defaults/
│   └── main.yml         # Default variables (optional)
└── meta/
    └── main.yml         # Role metadata and dependencies
```

## Usage

### Using Individual Roles

You can use individual roles in your playbook:

```yaml
---
- name: Deploy Monitoring Components
  hosts: monitoring_servers
  become: yes

  roles:
    - monitoring-common
    - prometheus
    - grafana
    - loki
    - alertmanager
    - node-exporter
    - cadvisor
    - promtail
```

### Using Multiple Roles

For a complete stack deployment, use multiple roles:

```yaml
---
- name: Deploy Complete Monitoring Stack
  hosts: monitoring_servers
  become: yes

  roles:
    - monitoring-common
    - prometheus
    - grafana
    - loki
    - alertmanager
    - cadvisor
```

### Selective Deployment

You can control which components to deploy using tags:

```yaml
---
- name: Deploy Selected Components
  hosts: monitoring_servers
  become: yes

  roles:
    - monitoring-common
    - role: prometheus
      tags: [prometheus]
    - role: grafana
      tags: [grafana]
    - role: alertmanager
      tags: [alertmanager]
```

Then run with specific tags:

```bash
ansible-playbook deploy-monitoring.yml --tags prometheus,grafana
```

## Configuration

### Global Configuration

Set these variables to apply to all components:

```yaml
# Base directory for all monitoring services
monitoring_base_dir: /opt/monitoring

# Docker network name
monitoring_network_name: monitoring

# Enable SSL/TLS
monitoring_ssl_enabled: false

# Enable backup
monitoring_enable_backup: true
monitoring_backup_retention_days: 7
```

### Component-Specific Configuration

Each role has its own variables that can be overridden:

#### Prometheus (Port: 9090)

```yaml
prometheus_port: 9090
prometheus_retention: "30d"
prometheus_scrape_interval: "15s"
prometheus_image: "prom/prometheus:latest"
```

#### Grafana (Port: 3000)

```yaml
grafana_port: 3000
grafana_admin_user: admin
grafana_admin_password: "SecurePassword123!"
grafana_image: "grafana/grafana:latest"
```

#### Loki (Port: 3100)

```yaml
loki_port: 3100
loki_retention_period: "744h"
loki_image: "grafana/loki:latest"
```

#### Alertmanager (Port: 9093)

```yaml
alertmanager_port: 9093
alertmanager_smtp_enabled: false
alertmanager_slack_enabled: false
alertmanager_image: "prom/alertmanager:latest"
```

#### Node Exporter (Port: 9100)

```yaml
node_exporter_port: 9100
node_exporter_log_level: "info"
```

#### cAdvisor (Port: 8080)

```yaml
cadvisor_port: 8080
cadvisor_docker_only: true
```

#### Promtail (Port: 9080)

```yaml
promtail_port: 9080
promtail_loki_url: "http://loki:3100"
```

## Port Usage

The monitoring stack uses the following ports:

| Service       | Port | Protocol | Purpose                   |
| ------------- | ---- | -------- | ------------------------- |
| Prometheus    | 9090 | HTTP     | Web UI and API            |
| Grafana       | 3000 | HTTP     | Web UI                    |
| Loki          | 3100 | HTTP     | Log ingestion and queries |
| Alertmanager  | 9093 | HTTP     | Web UI and API            |
| Node Exporter | 9100 | HTTP     | Metrics endpoint          |
| cAdvisor      | 8080 | HTTP     | Container metrics         |
| Promtail      | 9080 | HTTP     | Health and targets API    |

**Note**: Ensure these ports are available and not conflicting with other services on your hosts.

## Dependencies

### System Requirements

- Docker and Docker Compose installed
- Python Docker SDK (`python3-pip install docker docker-compose`)
- Sufficient disk space for data retention
- Network connectivity between components
- Available ports as listed above

### Role Dependencies

The roles have the following dependencies:

- All roles depend on `monitoring-common`
- `grafana` depends on `prometheus` and `loki` for data sources
- `prometheus` works with `alertmanager` for alerting
- `promtail` requires `loki` for log forwarding

## Examples

### Minimal Deployment

Deploy only Prometheus and Grafana:

```yaml
---
- name: Minimal Monitoring
  hosts: monitoring_servers
  become: yes

  roles:
    - monitoring-common
    - prometheus
    - grafana
```

### Production Deployment

Full stack with custom settings:

```yaml
---
- name: Production Monitoring Stack
  hosts: monitoring_servers
  become: yes

  vars:
    # Security
    monitoring_ssl_enabled: true
    grafana_admin_password: "{{ vault_grafana_password }}"

    # Retention
    prometheus_retention: "90d"
    loki_retention_period: "2160h" # 90 days

    # Resources
    monitoring_resource_limits:
      prometheus:
        memory: "4Gi"
        cpu: "2000m"
      grafana:
        memory: "1Gi"
        cpu: "1000m"

    # Alerting
    alertmanager_smtp_enabled: true
    alertmanager_smtp_server: "smtp.example.com:587"
    alertmanager_smtp_from: "monitoring@example.com"
    alertmanager_receiver_email: "ops-team@example.com"

  roles:
    - monitoring-common
    - prometheus
    - grafana
    - loki
    - alertmanager
    - cadvisor
```

### Adding Custom Scrape Targets

```yaml
prometheus_additional_scrape_targets:
  - job_name: "custom-app"
    static_configs:
      - targets: ["app1.example.com:8080", "app2.example.com:8080"]
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        regex: "([^:]+).*"
        replacement: "${1}"
```

## Maintenance

### Backup

The monitoring-common role includes a backup script:

```bash
/opt/monitoring/backup-monitoring.sh
```

Configure automated backups:

```yaml
monitoring_enable_backup: true
monitoring_backup_hour: "2"
monitoring_backup_minute: "0"
monitoring_backup_retention_days: 7
```

### Updates

For detailed update instructions, see the main [README.md](../../README.md#updating-components).

Quick update process:

1. Update image version in role's `vars/main.yml`
2. Run the deployment command (e.g., `make deploy-grafana`)

The deployment will automatically handle image pulling and container recreation.

### Health Checks

Check service status:

```bash
/opt/monitoring/scripts/check-services.sh
```

Or use the monitoring CLI:

```bash
monitoring status
monitoring logs prometheus
monitoring restart grafana
```

## Troubleshooting

### Common Issues

1. **Services not starting**: Check Docker logs

   ```bash
   docker logs prometheus
   docker logs grafana
   ```

2. **Network connectivity**: Verify Docker network

   ```bash
   docker network inspect monitoring
   ```

3. **Permission issues**: Check directory ownership

   ```bash
   ls -la /opt/monitoring/
   ```

4. **Resource constraints**: Monitor system resources
   ```bash
   docker stats
   free -h
   df -h
   ```

### Debug Mode

Enable debug logging:

```yaml
monitoring_debug_enabled: true
prometheus_log_level: "debug"
grafana_log_level: "debug"
```

## Migration Guide

For migration from older deployments, please see the [MIGRATION_GUIDE.md](../MIGRATION_GUIDE.md) in the parent directory. 4. Verify data persistence and service functionality

## Contributing

When adding new roles or features:

1. Follow the existing role structure
2. Include comprehensive documentation
3. Add appropriate tags for selective deployment
4. Test role independence and integration
5. Update this README with new configuration options

## License

These roles are provided under the MIT license.
