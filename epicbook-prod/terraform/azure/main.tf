terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "epicbook_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "epic_vnet" {
  name                = "epic-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.epicbook_rg.location
  resource_group_name = azurerm_resource_group.epicbook_rg.name
}

# Subnets
resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.epicbook_rg.name
  virtual_network_name = azurerm_virtual_network.epic_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "mysql_subnet" {
  name                 = "mysql-subnet"
  resource_group_name  = azurerm_resource_group.epicbook_rg.name
  virtual_network_name = azurerm_virtual_network.epic_vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "mysql-delegation"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Network Security Groups
resource "azurerm_network_security_group" "nsg_public" {
  name                = "nsg-public"
  location            = azurerm_resource_group.epicbook_rg.location
  resource_group_name = azurerm_resource_group.epicbook_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_source_ip
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
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Public Subnet
resource "azurerm_subnet_network_security_group_association" "public_nsg_assoc" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}

# Public IP with Standard SKU
resource "azurerm_public_ip" "vm_public_ip" {
  name                = "epicbook-vm-publicip"
  location            = azurerm_resource_group.epicbook_rg.location
  resource_group_name = azurerm_resource_group.epicbook_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interface
resource "azurerm_network_interface" "vm_nic" {
  name                = "epicbook-vm-nic"
  location            = azurerm_resource_group.epicbook_rg.location
  resource_group_name = azurerm_resource_group.epicbook_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "epicbook_vm" {
  name                = "epicbook-vm"
  resource_group_name = azurerm_resource_group.epicbook_rg.name
  location            = azurerm_resource_group.epicbook_rg.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(file("${path.module}/cloud-init.yml"))
}

# MySQL Flexible Server with Public Access
resource "azurerm_mysql_flexible_server" "epicbook_mysql" {
  name                = "epicbook-mysql-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.epicbook_rg.name
  location            = var.location

  administrator_login    = var.mysql_admin_username
  administrator_password = var.mysql_admin_password

  sku_name   = "B_Standard_B1s"
  version    = "8.0.21"

  storage {
    size_gb = 20
    iops    = 360
  }

  backup_retention_days = 7

  # Remove VNet integration and use public access
  # This is the default behavior when no network block is specified
}

# MySQL Firewall Rule - Allow VM access
resource "azurerm_mysql_flexible_server_firewall_rule" "vm_access" {
  name                = "allow-vm-access"
  resource_group_name = azurerm_resource_group.epicbook_rg.name
  server_name         = azurerm_mysql_flexible_server.epicbook_mysql.name
  start_ip_address    = azurerm_public_ip.vm_public_ip.ip_address
  end_ip_address      = azurerm_public_ip.vm_public_ip.ip_address
}

# Additional firewall rule for your local IP for testing
resource "azurerm_mysql_flexible_server_firewall_rule" "local_access" {
  name                = "allow-local-access"
  resource_group_name = azurerm_resource_group.epicbook_rg.name
  server_name         = azurerm_mysql_flexible_server.epicbook_mysql.name
  start_ip_address    = var.ssh_source_ip
  end_ip_address      = var.ssh_source_ip
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}