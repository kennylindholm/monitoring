# Ansible Infrastructure Management Boilerplate

This Ansible boilerplate provides a complete setup to install Docker and deploy a full monitoring stack (Grafana, Prometheus, Loki, Alertmanager) on Debian 12 servers. It includes best practices for Ansible project structure and production-ready monitoring deployment.

## Project Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── site.yml                 # Main playbook entry point
├── inventories/
│   └── hosts               # Server inventory
├── playbooks/
│   ├── install-docker.yml  # Docker installation playbook
│   └── deploy-monitoring.yml # Monitoring stack deployment
├── roles/
│   ├── docker/             # Docker installation role
│   │   ├── tasks/
│   │   ├── handlers/
│   │   └── vars/
│   └── monitoring-stack/   # Monitoring stack role
│       ├── tasks/
│       ├── handlers/
│       ├── templates/      # Configuration templates
│       ├── vars/
│       └── files/
└── examples/
    └── docker-compose.example.yml
```

## Prerequisites

1. **Ansible installed** on your control machine:
   ```bash
   # On Ubuntu/Debian
   sudo apt update && sudo apt install ansible
   
   # On macOS
   brew install ansible
   
   # Using pip
   pip3 install ansible
   ```

2. **SSH access** to your Debian 12 servers with sudo privileges

3. **SSH key authentication** configured (recommended)

## Quick Start

### 1. Configure Your Inventory

Edit `inventories/hosts` and replace the example servers with your actual servers:

```ini
[debian_servers]
your-server-1 ansible_host=YOUR_SERVER_IP ansible_user=YOUR_USERNAME
your-server-2 ansible_host=YOUR_SERVER_IP ansible_user=YOUR_USERNAME

[debian_servers:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_python_interpreter=/usr/bin/python3
```

### 2. Test Connectivity

Before running the playbook, test if Ansible can connect to your servers:

```bash
cd monitoring/ansible
ansible debian_servers -m ping
```

### 3. Deploy Infrastructure

Execute playbooks to install Docker and monitoring stack:

```bash
# Install Docker and deploy monitoring stack
ansible-playbook site.yml

# Install only Docker
ansible-playbook playbooks/install-docker.yml

# Deploy only monitoring stack (requires Docker)
ansible-playbook playbooks/deploy-monitoring.yml

# Run with system update (recommended for new servers)
ansible-playbook site.yml -e "update_system=true"
```

### 4. Target Specific Servers or Services

Run on specific servers or deploy specific services:

```bash
# Target specific server
ansible-playbook site.yml --limit your-server-1

# Deploy only Docker (skip monitoring)
ansible-playbook site.yml --tags docker

# Deploy only monitoring stack (skip Docker installation)
ansible-playbook site.yml --tags monitoring

# Target specific group
ansible-playbook site.yml --limit debian_servers
```

## Configuration Options

### Inventory Variables

You can customize the installation by setting variables in your inventory:

```ini
[debian_servers:vars]
# SSH configuration
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_python_interpreter=/usr/bin/python3
ansible_user=root

# Docker configuration
docker_users=['user1', 'user2']  # Users to add to docker group
update_system=true               # Update system packages before installation
```

### Playbook Variables

You can override variables when running the playbook:

```bash
# Add specific users to docker group
ansible-playbook site.yml -e "docker_users=['john','jane']"

# Update system packages before installation
ansible-playbook site.yml -e "update_system=true"
```

## What This Playbook Does

### Docker Installation
1. **System Verification**: Confirms the target is running Debian 12
2. **Package Updates**: Updates system packages (optional)
3. **Prerequisites**: Installs required packages (curl, ca-certificates, etc.)
4. **Docker Repository**: Adds Docker's official APT repository
5. **Docker Installation**: Installs Docker CE, CLI, containerd, and plugins
6. **Service Configuration**: Enables and starts Docker service
7. **User Management**: Adds specified users to the docker group
8. **Verification**: Tests Docker installation with hello-world container

### Monitoring Stack Deployment
1. **Infrastructure Setup**: Creates monitoring directories and configuration
2. **Service Deployment**: Deploys Prometheus, Grafana, Loki, and Alertmanager
3. **Monitoring Agents**: Installs Node Exporter, cAdvisor, and Promtail
4. **Configuration**: Sets up datasources, dashboards, and alert rules
5. **Health Checks**: Verifies all services are running and accessible
6. **Management Tools**: Creates management scripts and systemd service
7. **Firewall Configuration**: Optionally configures firewall rules

## Installed Components

### Docker Platform
- Docker CE (Community Edition)
- Docker CLI
- containerd.io
- Docker Buildx plugin
- Docker Compose plugin

### Monitoring Stack
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **Loki**: Log aggregation and analysis
- **Alertmanager**: Alert routing and management
- **Node Exporter**: System metrics collection
- **cAdvisor**: Container metrics collection
- **Promtail**: Log collection agent

## Post-Installation

### Docker Commands
```bash
# Check Docker version
docker --version

# Run a test container
docker run hello-world

# Use Docker Compose
docker compose version

# Check Docker service status
systemctl status docker
```

### Monitoring Stack Access
After deployment, access your monitoring services:

- **Grafana**: http://YOUR_SERVER_IP:3000 (admin/admin123)
- **Prometheus**: http://YOUR_SERVER_IP:9090
- **Loki**: http://YOUR_SERVER_IP:3100
- **Alertmanager**: http://YOUR_SERVER_IP:9093

### Monitoring Stack Management
```bash
# Use the management script
/opt/monitoring/manage-stack.sh status
/opt/monitoring/manage-stack.sh logs
/opt/monitoring/manage-stack.sh restart

# Or use the shortcuts
monitoring-stack status
monitoring-stack health
monitoring-stack backup

# Using Make commands
make monitoring-status
make monitoring-logs
make monitoring-health
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: If you get permission errors, ensure your user is in the docker group:
   ```bash
   sudo usermod -aG docker $USER
   # Log out and back in for changes to take effect
   ```

2. **SSH Connection Issues**: 
   - Verify SSH key authentication is working
   - Check if the ansible_user has sudo privileges
   - Ensure Python 3 is installed on target servers

3. **Repository Issues**: If APT repository addition fails:
   - Check internet connectivity on target servers
   - Verify DNS resolution is working

### Debug Mode

Run playbooks with increased verbosity for debugging:

```bash
ansible-playbook site.yml -v    # Verbose
ansible-playbook site.yml -vv   # More verbose
ansible-playbook site.yml -vvv  # Debug level
```

### Check Mode (Dry Run)

Test what changes would be made without applying them:

```bash
ansible-playbook site.yml --check
ansible-playbook playbooks/deploy-monitoring.yml --check
```

## Security Considerations

1. **SSH Keys**: Use SSH key authentication instead of passwords
2. **User Privileges**: Use a dedicated user with sudo privileges instead of root when possible
3. **Firewall**: Configure appropriate firewall rules for Docker
4. **Network**: Secure Docker daemon socket if exposing over network

## Available Make Commands

```bash
# Docker Installation
make install              # Install Docker on all servers
make install-update       # Install Docker with system updates
make test                 # Test Docker installation

# Monitoring Stack
make deploy-monitoring    # Deploy complete monitoring stack
make monitoring-status    # Show monitoring stack status
make monitoring-logs      # Show monitoring stack logs
make monitoring-health    # Check monitoring stack health
make monitoring-backup    # Create backup of monitoring data

# Development
make check                # Run playbooks in check mode
make syntax               # Check playbook syntax
make ping                 # Test server connectivity
```

## Monitoring Stack Configuration

### Default Services and Ports
- Grafana: 3000
- Prometheus: 9090
- Loki: 3100
- Alertmanager: 9093
- Node Exporter: 9100
- cAdvisor: 8080

### Customization Options
Override default settings:

```bash
# Custom Grafana password
make deploy-monitoring-custom EXTRA_VARS="grafana_admin_password=mysecretpass"

# Custom ports
ansible-playbook playbooks/deploy-monitoring.yml -e "grafana_port=3001 prometheus_port=9091"

# Disable certain components
ansible-playbook playbooks/deploy-monitoring.yml -e "cadvisor_enabled=false"
```

### Data Persistence
All monitoring data is stored in `/opt/monitoring/` with the following structure:
```
/opt/monitoring/
├── prometheus/data/      # Metrics data
├── grafana/data/         # Dashboards and users
├── loki/data/           # Log data
├── alertmanager/data/   # Alert state
└── configs/             # Service configurations
```

## Extending the Boilerplate

This boilerplate can be extended with additional roles:

1. **Security**: Implement security hardening
2. **Applications**: Deploy containerized applications
3. **Backup**: Implement automated backup strategies
4. **Load Balancing**: Add nginx or HAProxy for load balancing
5. **SSL/TLS**: Implement SSL termination and certificate management

## License

This boilerplate is provided as-is for educational and production use.