#!/bin/bash

DATA_DIR=/data/vm

echo "Clean data"
sudo rm -rf $DATA_DIR/*

echo "Destroy libvirt resources"
virsh pool-destroy ubuntu || true && virsh pool-undefine ubuntu || true