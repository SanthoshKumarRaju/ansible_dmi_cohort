output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.web_rg.name
}

output "vm_public_ips" {
  description = "Public IP addresses of VMs with public IPs"
  value       = slice(azurerm_linux_virtual_machine.web_vm[*].public_ip_address, 0, 2)
}

output "vm_private_ips" {
  description = "Private IP addresses of all VMs"
  value       = azurerm_linux_virtual_machine.web_vm[*].private_ip_address
}

output "bastion_host_name" {
  description = "Bastion host name for SSH access"
  value       = azurerm_bastion_host.web_bastion.name
}

output "ssh_private_key_path" {
  description = "Path to the generated SSH private key"
  value       = local_file.ssh_private_key.filename
}

output "vm_details" {
  description = "Details of all created VMs"
  value = [for i in range(var.vm_count) : {
    vm_name    = azurerm_linux_virtual_machine.web_vm[i].name
    public_ip  = azurerm_linux_virtual_machine.web_vm[i].public_ip_address
    private_ip = azurerm_linux_virtual_machine.web_vm[i].private_ip_address
    has_public_ip = i < 2
  }]
}