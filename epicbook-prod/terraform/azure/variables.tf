variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "epicbook-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "Central US"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_source_ip" {
  description = "Your IP address for SSH access (format: X.X.X.X without /32)"
  type        = string
  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.ssh_source_ip))
    error_message = "The ssh_source_ip must be a valid IPv4 address without CIDR notation (e.g., 192.168.1.1)."
  }
}

variable "mysql_admin_username" {
  description = "MySQL admin username"
  type        = string
  default     = "admin_s"
}

variable "mysql_admin_password" {
  description = "MySQL admin password"
  type        = string
  sensitive   = true
}