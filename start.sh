#!/bin/bash

N_SLAVES=$1
JAR_FILE=$2
N_INSTANCES=$((N_SLAVES + 1))

VM_USERNAME=ubuntu

HOME=$(pwd)
ANSIBLE_DIR=$HOME/ansible
TERRAFORM_DIR=$HOME/terraform

# == 1. Launch the VMs using Terraform
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
echo "Finished creating VMs, master node: ${MASTER_IP}, worker nodes: ${WORKER_IPS}"

# == 2. Install Hadoop/Spark clusters using Ansible
(
    cd ansible || exit

    # Run the playbook
    echo "Installing Hadoop/Spark clusters..."
    ansible-playbook -i inventory/servers.ini --private-key $HOME/secrets/id_ed25519 playbook.yml
)

# # == 3. Run the Spark job
# (
#     cd ansible || exit

#     # Run the playbook
#     echo "Running Spark job..."
#     ansible-playbook -i inventory/servers.ini --private-key $HOME/secrets/id_ed25519 spark-job.yml
# )