# Migration Guide: From Monolithic to Modular Monitoring Stack

This guide helps you transition from the legacy monolithic monitoring deployment to the modern modular architecture.

## Overview of Changes

### Old Architecture (Monolithic)

- Single monolithic role that deployed everything (now removed)
- Used by `deploy-monitoring.yml` playbook (now archived)
- All-or-nothing deployment
- Limited configuration flexibility

### New Architecture (Modular)

- Individual roles for each component (prometheus, grafana, loki, etc.)
- Orchestrated by `monitoring-meta` role
- Selective component deployment
- Extensive configuration options

## Migration Steps

### Step 1: Backup Existing Data

Before migrating, backup your existing monitoring data:

```bash
# Backup all monitoring data
sudo tar -czf /opt/monitoring-backup-$(date +%Y%m%d-%H%M%S).tar.gz /opt/monitoring

# Or use the Make command if available
make monitoring-backup
```

### Step 2: Update Your Inventory

The new architecture uses `monitoring_servers` instead of `debian_servers`:

**Old inventory:**

```ini
[debian_servers]
monitoring-1 ansible_host=192.168.1.10 ansible_user=root
```

**New inventory:**

```ini
[monitoring_servers]
monitoring-1 ansible_host=192.168.1.10 ansible_user=root

# For backward compatibility
[debian_servers:children]
monitoring_servers
```

### Step 3: Update Your Playbook References

**Old approach:**

```bash
ansible-playbook playbooks/deploy-monitoring.yml
```

**New approach:**

```bash
# Recommended: Deploy all components
ansible-playbook playbooks/deploy-monitoring-all.yml

# Or use Make commands
make deploy-monitoring
```

### Step 4: Update Variable Names

Some variable names have changed for consistency:

| Old Variable             | New Variable                      | Notes                    |
| ------------------------ | --------------------------------- | ------------------------ |
| `grafana_admin_password` | `meta_grafana_admin_password`     | When using meta role     |
| `prometheus_retention`   | `prometheus_retention`            | Same, but scoped to role |
| `loki_retention_period`  | `loki_retention_period`           | Same, but scoped to role |
| `node_exporter_enabled`  | `monitoring_deploy_node_exporter` | Boolean flag             |
| `cadvisor_enabled`       | `monitoring_deploy_cadvisor`      | Boolean flag             |
| `promtail_enabled`       | `monitoring_deploy_promtail`      | Boolean flag             |

### Step 5: Migrate Custom Configurations

If you have custom configurations, they need to be migrated to the new structure:

**Old location:**

```
/opt/monitoring/configs/
├── prometheus.yml
├── grafana.ini
└── loki-config.yml
```

**New location:**

```
/opt/monitoring/
├── prometheus/configs/prometheus.yml
├── grafana/configs/grafana.ini
└── loki/configs/loki-config.yml
```

## Common Migration Scenarios

### Scenario 1: Simple Full Stack Migration

If you were using the default configuration:

```bash
# Deploy the new stack (data will be preserved)
make deploy-monitoring

# Verify all services are running
make monitoring-status
```

### Scenario 2: Custom Configuration Migration

If you have custom configurations:

```bash
# 1. Backup your custom configs
cp -r /opt/monitoring/configs /opt/monitoring-configs-backup

# 2. Deploy with your custom settings
make deploy-monitoring EXTRA_VARS="meta_grafana_admin_password=YourPassword prometheus_retention=90d"

# 3. Copy your custom configs to new locations
# (The new structure creates separate config directories for each service)
```

### Scenario 3: Partial Stack Migration

If you only want specific components:

```bash
# Deploy only Prometheus and Grafana
make deploy-monitoring EXTRA_VARS="monitoring_deploy_loki=false monitoring_deploy_alertmanager=false"

# Or use individual deployment
make deploy-prometheus
make deploy-grafana
```

### Scenario 4: Gradual Migration

For zero-downtime migration:

```bash
# 1. Deploy new stack on different ports
ansible-playbook playbooks/deploy-monitoring-all.yml \
  -e "prometheus_port=9091 grafana_port=3001 loki_port=3101"

# 2. Verify new stack is working
# 3. Migrate data if needed
# 4. Switch ports and remove old stack
```

## Verification Steps

After migration, verify everything is working:

```bash
# Check service status
make monitoring-status

# Check service health
make monitoring-health

# View service URLs
make monitoring-urls

# Check logs for any errors
make monitoring-logs
```

## Rollback Plan

If you need to rollback:

1. **Stop the new stack:**

   ```bash
   make monitoring-stop
   ```

2. **Restore from backup:**

   ```bash
   sudo tar -xzf /opt/monitoring-backup-TIMESTAMP.tar.gz -C /
   ```

3. **Use the legacy playbook:**

   ```bash
   # The old playbook is archived at:
   ansible-playbook playbooks/legacy/deploy-monitoring.yml.bak
   # Note: The monolithic role has been removed, so this will no longer work
   ```

## Benefits After Migration

1. **Selective Updates**: Update individual components without affecting others
2. **Better Resource Management**: Enable/disable components as needed
3. **Improved Configuration**: More granular control over each service
4. **Easier Troubleshooting**: Issues are isolated to specific components
5. **Future Compatibility**: New features will only be added to modular roles

## Troubleshooting

### Issue: Services fail to start after migration

Check if ports are already in use:

```bash
sudo netstat -tlnp | grep -E '9090|3000|3100|9093'
```

### Issue: Missing data after migration

Data is now stored in component-specific directories:

```bash
# Old: /opt/monitoring/data/
# New: /opt/monitoring/prometheus/data/
#      /opt/monitoring/grafana/data/
#      /opt/monitoring/loki/data/
```

### Issue: Custom dashboards missing

Grafana dashboards are now in:

```bash
/opt/monitoring/grafana/dashboards/
```

## Getting Help

If you encounter issues during migration:

1. Check the logs: `make monitoring-logs`
2. Review the component-specific README files in each role directory
3. Use check mode to preview changes: `make check`

## Timeline

- **Completed**: Monolithic role has been removed
- **Current**: Only the modular approach is supported
- **Legacy**: The old `deploy-monitoring.yml` playbook is archived for reference only

Migration to the modular approach is now required.
