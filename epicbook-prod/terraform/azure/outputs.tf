output "vm_public_ip" {
  description = "Public IP of the VM"
  value       = azurerm_public_ip.vm_public_ip.ip_address
}

output "admin_username" {
  description = "Admin username for the VM"
  value       = var.admin_username
}

output "mysql_host" {
  description = "MySQL server hostname"
  value       = azurerm_mysql_flexible_server.epicbook_mysql.fqdn
}

output "mysql_database_name" {
  description = "MySQL database name"
  value       = "epicbook"
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${azurerm_public_ip.vm_public_ip.ip_address}"
}