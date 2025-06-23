#!/bin/bash

# Configuration - VMs to manage
VMS="debian12 debian12-clone1 debian12-clone2 debian12-clone3 debian12-monitoringtest"

# Function to display usage information
usage() {
    echo "Usage: $0 {start|stop|status}"
    echo "  start  - Start the VMs"
    echo "  stop   - Stop the VMs"
    echo "  status - Show current VM status"
    exit 1
}

# Function to check VM status
check_vm_status() {
    echo "Checking current VM status..."
    echo "================================"
    virsh -c qemu:///system list --all
    echo "================================"
    echo ""
}

# Start VMs
start_vms() {
    check_vm_status

    echo "Starting VMs: $VMS"
    local failed=0

    # Start each VM individually
    for vm in $VMS; do
        echo "Starting VM: $vm"
        virsh -c qemu:///system start "$vm"
        if [ $? -ne 0 ]; then
            echo "Failed to start VM: $vm"
            failed=1
        else
            echo "Successfully started VM: $vm"
        fi
    done

    if [ $failed -eq 0 ]; then
        echo "All VMs started successfully"
    else
        echo "Some VMs failed to start"
        exit 1
    fi

    echo ""
    echo "Final VM status:"
    check_vm_status
}

# Stop VMs
stop_vms() {
    check_vm_status

    echo "Stopping VMs: $VMS"
    local failed=0

    # Stop each VM individually
    for vm in $VMS; do
        echo "Stopping VM: $vm"
        virsh -c qemu:///system shutdown "$vm"
        if [ $? -ne 0 ]; then
            echo "Failed to stop VM: $vm"
            failed=1
        else
            echo "Successfully stopped VM: $vm"
        fi
    done

    if [ $failed -eq 0 ]; then
        echo "All VMs stopped successfully"
    else
        echo "Some VMs failed to stop"
        exit 1
    fi

    echo ""
    echo "Final VM status:"
    check_vm_status
}

# Main function
main() {
    # Check if argument is provided
    if [ $# -eq 0 ]; then
        echo "Error: No command specified"
        usage
    fi

    # Process command line argument
    case "$1" in
        start)
            start_vms
            ;;
        stop)
            stop_vms
            ;;
        status)
            check_vm_status
            ;;
        *)
            echo "Error: Invalid command '$1'"
            usage
            ;;
    esac
}

# Call main function with all arguments
main "$@"
