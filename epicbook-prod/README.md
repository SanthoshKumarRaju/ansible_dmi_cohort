
# EpicBook Production Deployment

This project automates the deployment of EpicBook application on Azure using Terraform and Ansible.

## Architecture

- Azure VM (Ubuntu 22.04) in public subnet
- Azure MySQL Flexible Server in private subnet
- Nginx reverse proxy
- Node.js application with MySQL backend

## Prerequisites

1. Azure CLI installed and logged in
2. Terraform installed
3. Ansible installed
4. SSH key pair (~/.ssh/id_rsa and ~/.ssh/id_rsa.pub)

## Deployment Steps

### 1. Terraform Setup

```bash
cd terraform/azure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply