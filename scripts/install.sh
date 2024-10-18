#!/bin/bash

DATA_DIR=/data/vm

# == Libvirt/KVM
sudo apt update -y
sudo apt -y install bridge-utils cpu-checker libvirt-clients libvirt-daemon-system qemu-kvm
kvm-ok

# == Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update -y && sudo apt install -y terraform

# Install genisoimage for mkisofs for cloudinit feature
sudo apt install -y genisoimage

# Disable qemu security_driver to fix permission error in ubuntu
# https://github.com/dmacvicar/terraform-provider-libvirt/issues/546
sudo sed -i 's/#security_driver = "selinux"/security_driver = "none"/' /etc/libvirt/qemu.conf
sudo systemctl restart libvirtd

# == Ansible

# == Prepare VM envs
sudo usermod -aG libvirt `id -un`
sudo usermod -aG kvm `id -un`

mkdir -p $DATA_DIR || true
sudo chown -R $USER:libvirt $DATA_DIR