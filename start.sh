#!/bin/bash

# Record running time
START_TIME=$SECONDS

# Parameters
N_SLAVES=$1
FILE_JAR_PATH=$(realpath $2)
FILE_DATA_PATH=$(realpath $3)
JOB_CLASS_NAME=$4

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

    echo "Installing Hadoop/Spark clusters..."
    ansible-playbook install.yml \
        -i inventory/servers.ini \
        --private-key $HOME/secrets/id_ed25519
)

# == 3. Run the Spark job
(
    echo "Clean old output..."
    rm -rf /tmp/output || true

    cd ansible || exit

    echo "Running Spark job..."
    ansible-playbook spark-job.yml  \
        -i inventory/servers.ini \
        --private-key $HOME/secrets/id_ed25519 \
        -e file_jar_path=$FILE_JAR_PATH \
        -e file_data_path=$FILE_DATA_PATH \
        -e jar_class_name=$JOB_CLASS_NAME
)

# == 4. Stop the VMs
(
    cd terraform || exit

    echo "Stopping the VMs..."
    terraform destroy -auto-approve
)

ELAPSED_TIME=$(($SECONDS - $START_TIME))

echo ""
echo "Finished running the Spark job."
echo " - Number of Slave nodes: $N_SLAVES"
echo " - JAR file path: $FILE_JAR_PATH"
echo " - Data file path: $FILE_DATA_PATH"
echo " - Job class name: $JOB_CLASS_NAME"
echo " - Output directory: /tmp/output"
echo " - Time taken: $ELAPSED_TIME seconds"