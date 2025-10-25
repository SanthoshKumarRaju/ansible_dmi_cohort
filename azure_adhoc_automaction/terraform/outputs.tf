output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}

output "vm_public_ips" {
  description = "Public IP addresses of all VMs"
  value       = azurerm_public_ip.main[*].ip_address
}

output "vm_details" {
  description = "Details of all VMs"
  value = [for i in range(var.vm_count) : {
    name       = azurerm_linux_virtual_machine.main[i].name
    public_ip  = azurerm_public_ip.main[i].ip_address
    role       = local.vm_roles[i]
    private_ip = azurerm_network_interface.main[i].private_ip_address
  }]
}

output "ssh_connection_commands" {
  description = "SSH connection commands for each VM"
  value = [for i in range(var.vm_count) : 
    "ssh ${var.admin_username}@${azurerm_public_ip.main[i].ip_address} -i ~/.ssh/id_rsa"
  ]
}