# Configure Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate random resource group name
resource "random_pet" "rg_name" {
  prefix = "web"
}

# Create resource group
resource "azurerm_resource_group" "web_rg" {
  name     = random_pet.rg_name.id
  location = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "web_vnet" {
  name                = "web-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name
}

# Create subnet for web servers
resource "azurerm_subnet" "web_subnet" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.web_rg.name
  virtual_network_name = azurerm_virtual_network.web_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create subnet for bastion host
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"  # Required name for Bastion
  resource_group_name  = azurerm_resource_group.web_rg.name
  virtual_network_name = azurerm_virtual_network.web_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create only 2 public IPs (within your 3 IP limit)
resource "azurerm_public_ip" "web_public_ip" {
  count               = 2  # Only 2 public IPs for first two VMs
  name                = "web-public-ip-${count.index}"
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create public IP for Bastion
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "bastion-public-ip"
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create Bastion Host
resource "azurerm_bastion_host" "web_bastion" {
  name                = "web-bastion"
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}

# Create network security group
resource "azurerm_network_security_group" "web_nsg" {
  name                = "web-nsg"
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interfaces - first 2 with public IPs, others without
resource "azurerm_network_interface" "web_nic" {
  count               = var.vm_count
  name                = "web-nic-${count.index}"
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = count.index < 2 ? azurerm_public_ip.web_public_ip[count.index].id : null
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "web_nic_nsg" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.web_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

# Create SSH key
resource "tls_private_key" "web_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save SSH key locally with proper permissions using provisioner
resource "local_file" "ssh_private_key" {
  content         = tls_private_key.web_ssh.private_key_pem
  filename        = "../ansible/azure_private_key.pem"
  file_permission = "0600"  # This should work, but add provisioner as backup

  # Add provisioner to ensure permissions are set correctly
  provisioner "local-exec" {
    command = "chmod 600 ../ansible/azure_private_key.pem"
  }
}

resource "local_file" "ssh_public_key" {
  content  = tls_private_key.web_ssh.public_key_openssh
  filename = "../ansible/azure_public_key.pub"
  file_permission = "0644"
}

# Create virtual machines
resource "azurerm_linux_virtual_machine" "web_vm" {
  count               = var.vm_count
  name                = "web-vm-${count.index}"
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  computer_name       = "webvm${count.index}"
  admin_password      = var.admin_password 

  network_interface_ids = [
    azurerm_network_interface.web_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.web_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
    admin_username      = var.admin_username
    ssh_public_key      = tls_private_key.web_ssh.public_key_openssh
  }))

  # Fixed provisioner - using heredoc syntax for complex commands
  provisioner "local-exec" {
    command = <<EOT
      echo "VM ${count.index} - Public IP: ${self.public_ip_address} - Private IP: ${self.private_ip_address}" >> ../ansible/vm_ips.txt
    EOT
  }
}

# NO OUTPUTS IN THIS FILE - They are in outputs.tf