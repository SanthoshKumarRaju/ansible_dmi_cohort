variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "ad-hoc-automation-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 3
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key path"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}