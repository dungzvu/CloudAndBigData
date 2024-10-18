#!/bin/bash

N_SLAVES=$1
N_INSTANCES=$((N_SLAVES + 1))

HOME=$(pwd)
ANSIBLE_DIR=$HOME/ansible
TERRAFORM_DIR=$HOME/terraform

# Run terraform commands in a subshell
(
    cd terraform || exit
    # Check if the .terraform directory exists
    if [ ! -d ".terraform" ]; then
        echo "Initializing Terraform..."
        terraform init
    else
        echo "Terraform already initialized."
    fi
    
    echo "Creating $N_INSTANCES VMs..."
    terraform apply -auto-approve -var instance_count=$N_INSTANCES

    # Get the IP addresses of the VMs
    echo "Create Ansible inventory file..."
     # Extract IP addresses and format them for the Ansible inventory file
    MASTER_IP=$(terraform output -json | jq -r '.ips.value[0]')
    WORKER_IPS=$(terraform output -json | jq -r '.ips.value[1:][]')

    # Write to the servers.ini file
    {
        echo "[master]"
        echo "master ansible_host=${MASTER_IP}"
        echo ""
        echo "[workers]"
        i=1
        for ip in ${WORKER_IPS}; do
            echo "worker${i} ansible_host=${ip}"
            i=$((i + 1))
        done
    } > "${ANSIBLE_DIR}/inventory/servers.ini"
)