#!/bin/bash

cd terraform || exit

# Check if the .terraform directory exists
if [ ! -d ".terraform" ]; then
    echo "No running VMs to stop."
    exit
fi

terraform apply -auto-approve -var instance_count=0