#!/bin/bash

# Configuration - VMs to manage
VMS="debian12-monitoring debian12-app1 debian12-app2"

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

# Function to get VM state
get_vm_state() {
    local vm_name="$1"
    virsh -c qemu:///system domstate "$vm_name" 2>/dev/null
}

# Function to check if VM is running
is_vm_running() {
    local vm_name="$1"
    local state=$(get_vm_state "$vm_name")
    [ "$state" = "running" ]
}

# Function to check if VM is stopped
is_vm_stopped() {
    local vm_name="$1"
    local state=$(get_vm_state "$vm_name")
    [ "$state" = "shut off" ] || [ "$state" = "shutoff" ]
}

# Start VMs
start_vms() {
    check_vm_status

    echo "Starting VMs: $VMS"
    local failed=0
    local started=0
    local skipped=0

    # Start each VM individually
    for vm in $VMS; do
        if is_vm_running "$vm"; then
            echo "Skipping VM: $vm (already running)"
            skipped=$((skipped + 1))
        elif is_vm_stopped "$vm"; then
            echo "Starting VM: $vm"
            virsh -c qemu:///system start "$vm"
            if [ $? -ne 0 ]; then
                echo "Failed to start VM: $vm"
                failed=1
            else
                echo "Successfully started VM: $vm"
                started=$((started + 1))
            fi
        else
            echo "Skipping VM: $vm (unknown state: $(get_vm_state "$vm"))"
            skipped=$((skipped + 1))
        fi
    done

    echo ""
    echo "Summary: $started started, $skipped skipped, $failed failed"

    if [ $failed -eq 0 ]; then
        if [ $started -eq 0 ]; then
            echo "No VMs needed to be started"
        else
            echo "All applicable VMs started successfully"
        fi
    else
        echo "Some VMs failed to start"
        exit 1
    fi

    echo ""
    echo "Final VM status:"
    check_vm_status
}

# Function to wait for VM to shutdown
wait_for_vm_shutdown() {
    local vm_name="$1"
    local max_wait=60  # Maximum wait time in seconds
    local wait_time=0

    echo "Waiting for $vm_name to shut down..."
    while [ $wait_time -lt $max_wait ]; do
        if is_vm_stopped "$vm_name"; then
            echo "$vm_name has shut down successfully"
            return 0
        fi

        printf "."
        sleep 2
        wait_time=$((wait_time + 2))
    done

    echo ""
    echo "Warning: $vm_name did not shut down within $max_wait seconds"
    return 1
}

# Stop VMs
stop_vms() {
    check_vm_status

    echo "Stopping VMs sequentially: $VMS"
    local failed=0
    local stopped=0
    local skipped=0

    # Stop each VM individually and wait for each one to shut down completely
    for vm in $VMS; do
        if is_vm_stopped "$vm"; then
            echo "Skipping VM: $vm (already stopped)"
            skipped=$((skipped + 1))
        elif is_vm_running "$vm"; then
            echo "Stopping VM: $vm"
            virsh -c qemu:///system shutdown "$vm"
            if [ $? -ne 0 ]; then
                echo "Failed to send shutdown command to VM: $vm"
                failed=1
            else
                echo "Shutdown command sent to VM: $vm"
                # Wait for this VM to shut down before continuing
                if wait_for_vm_shutdown "$vm"; then
                    echo "VM $vm has shut down successfully"
                    stopped=$((stopped + 1))
                else
                    echo "VM $vm did not shut down gracefully within timeout"
                    failed=1
                fi
            fi
        else
            echo "Skipping VM: $vm (unknown state: $(get_vm_state "$vm"))"
            skipped=$((skipped + 1))
        fi
        echo ""  # Add spacing between VM operations
    done

    echo "Summary: $stopped stopped, $skipped skipped, $failed failed"

    if [ $failed -eq 0 ]; then
        if [ $stopped -eq 0 ]; then
            echo "No VMs needed to be stopped"
        else
            echo "All applicable VMs stopped successfully"
        fi
    else
        echo "Some VMs failed to stop gracefully"
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
