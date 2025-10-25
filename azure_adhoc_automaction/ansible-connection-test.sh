#!/bin/bash
echo "=== Testing Direct SSH Connectivity ==="

WEB_IP="52.191.54.181"
APP_IP="172.191.46.31"
DB_IP="172.191.124.66"
USER="azureuser"
KEY="~/.ssh/id_rsa"

echo "Testing Web VM..."
ssh $USER@$WEB_IP -i $KEY "echo 'Web: ' && hostname && whoami"

echo "Testing App VM..."
ssh $USER@$APP_IP -i $KEY "echo 'App: ' && hostname && whoami"

echo "Testing DB VM..."
ssh $USER@$DB_IP -i $KEY "echo 'DB: ' && hostname && whoami"

echo "=== Testing Ansible ==="
ansible all -i inventory.ini -m ping

echo "=== Basic Ansible Commands ==="
ansible all -i inventory.ini -m command -a "uptime"
