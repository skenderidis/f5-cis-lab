#!/usr/bin/env bash
# Filename: configure.sh

cd ansible
ansible-playbook create-inventories.yml
ansible-playbook setup-k8s.yml -i k8s-inventory.ini
ansible-playbook setup-flannel.yml -i k8s-inventory.ini
ansible-playbook deploy-nginx-cis.yml -i k8s-inventory.ini
