variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "Central US"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "adminuser"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "mini-finance-rg"
}