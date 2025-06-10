# Ansible Docker Installation Makefile
# Common operations for managing Docker installation via Ansible

.PHONY: help ping install install-update check syntax lint clean test

# Default target
help:
	@echo "Available targets:"
	@echo "  ping           - Test connectivity to all servers"
	@echo "  install        - Install Docker on all Debian servers"
	@echo "  install-update - Install Docker with system updates"
	@echo "  check          - Run playbook in check mode (dry run)"
	@echo "  syntax         - Check playbook syntax"
	@echo "  lint           - Lint playbooks with ansible-lint"
	@echo "  test           - Test Docker installation"
	@echo "  clean          - Clean up temporary files"
	@echo "  help           - Show this help message"

# Test connectivity to all servers
ping:
	ansible debian_servers -m ping

# Install Docker on all servers
install:
	ansible-playbook site.yml

# Install Docker with system updates
install-update:
	ansible-playbook site.yml -e "update_system=true"

# Run in check mode (dry run)
check:
	ansible-playbook site.yml --check

# Check syntax of playbooks
syntax:
	ansible-playbook site.yml --syntax-check
	ansible-playbook playbooks/install-docker.yml --syntax-check

# Lint playbooks (requires ansible-lint)
lint:
	@which ansible-lint > /dev/null || (echo "ansible-lint not found. Install with: pip install ansible-lint" && exit 1)
	ansible-lint site.yml
	ansible-lint playbooks/install-docker.yml

# Test Docker installation
test:
	ansible debian_servers -a "docker --version"
	ansible debian_servers -a "docker compose version"

# Clean up temporary files
clean:
	find . -name "*.retry" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete

# Install specific server
install-server:
	@if [ -z "$(SERVER)" ]; then echo "Usage: make install-server SERVER=server-name"; exit 1; fi
	ansible-playbook site.yml --limit $(SERVER)

# Variables that can be overridden
ANSIBLE_ARGS ?=
EXTRA_VARS ?=

# Advanced targets with custom arguments
install-custom:
	ansible-playbook site.yml $(ANSIBLE_ARGS) $(if $(EXTRA_VARS),-e "$(EXTRA_VARS)")

# Show inventory
inventory:
	ansible-inventory --list

# Show facts for all servers
facts:
	ansible debian_servers -m setup

# Update system packages only
update-system:
	ansible debian_servers -m apt -a "upgrade=dist update_cache=yes autoremove=yes" --become

# Examples of usage:
# make install
# make install-update
# make check
# make install-server SERVER=debian-server-1
# make install-custom EXTRA_VARS="docker_users=['user1','user2']"