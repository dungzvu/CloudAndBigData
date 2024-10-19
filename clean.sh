#!/bin/bash

cd terraform || exit

# Check if the .terraform directory exists
if [ ! -d ".terraform" ]; then
    echo "No running VMs to destroy."
    exit
fi

terraform destroy -auto-approve