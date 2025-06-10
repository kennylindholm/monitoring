# Ansible Docker Installation Boilerplate

This Ansible boilerplate provides a complete setup to install Docker on Debian 12 servers. It includes best practices for Ansible project structure and Docker installation.

## Project Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── site.yml                 # Main playbook entry point
├── inventories/
│   └── hosts               # Server inventory
├── playbooks/
│   └── install-docker.yml  # Docker installation playbook
└── roles/
    └── docker/
        ├── tasks/
        │   └── main.yml    # Docker installation tasks
        ├── handlers/
        │   └── main.yml    # Service handlers
        └── vars/
            └── main.yml    # Role variables
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

### 3. Run the Docker Installation

Execute the playbook to install Docker:

```bash
# Install Docker on all Debian servers
ansible-playbook site.yml

# Or run the specific Docker playbook
ansible-playbook playbooks/install-docker.yml

# Run with system update (recommended for new servers)
ansible-playbook playbooks/install-docker.yml -e "update_system=true"
```

### 4. Target Specific Servers

Run on specific servers or groups:

```bash
# Target specific server
ansible-playbook site.yml --limit your-server-1

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

1. **System Verification**: Confirms the target is running Debian 12
2. **Package Updates**: Updates system packages (optional)
3. **Prerequisites**: Installs required packages (curl, ca-certificates, etc.)
4. **Docker Repository**: Adds Docker's official APT repository
5. **Docker Installation**: Installs Docker CE, CLI, containerd, and plugins
6. **Service Configuration**: Enables and starts Docker service
7. **User Management**: Adds specified users to the docker group
8. **Verification**: Tests Docker installation with hello-world container
9. **Docker Compose**: Verifies Docker Compose plugin installation

## Installed Components

- Docker CE (Community Edition)
- Docker CLI
- containerd.io
- Docker Buildx plugin
- Docker Compose plugin

## Post-Installation

After successful installation, you can:

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
```

## Security Considerations

1. **SSH Keys**: Use SSH key authentication instead of passwords
2. **User Privileges**: Use a dedicated user with sudo privileges instead of root when possible
3. **Firewall**: Configure appropriate firewall rules for Docker
4. **Network**: Secure Docker daemon socket if exposing over network

## Extending the Boilerplate

This boilerplate can be extended with additional roles:

1. **Monitoring**: Add Prometheus, Grafana, or other monitoring tools
2. **Security**: Implement security hardening
3. **Applications**: Deploy containerized applications
4. **Backup**: Implement backup strategies

## License

This boilerplate is provided as-is for educational and production use.