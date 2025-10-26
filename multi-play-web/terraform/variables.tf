variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US 2"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 4  # Reduced for free tier
}

variable "vm_size" {
  description = "Size of the VMs"
  type        = string
  default     = "Standard_B1s"  # Free tier eligible
}

variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
  default     = "azureuser"
}

variable "use_standard_public_ip" {
  description = "Use Standard SKU for public IPs instead of Basic"
  type        = bool
  default     = true
}

variable "admin_password" {
  description = "Admin password for the VMs"
  type        = string
  sensitive   = true
  default     = "Azure123456789!"  # Set a default password
}