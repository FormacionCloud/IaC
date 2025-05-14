output "public_ip_address" {
  description = "Public IP of the VM"
  value       = azurerm_public_ip.public_ip.ip_address
}
