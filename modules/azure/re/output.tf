output "re-nodes" {
  description = "The Redis Enterprise nodes"
  value       = azurerm_linux_virtual_machine.nodes
  sensitive   = true
}

output "re-public-ips" {
  description = "Public IP addresses of all Redis cluster nodes"
  value       = azurerm_linux_virtual_machine.nodes[*].public_ip_address
}

output "re-private-ips" {
  description = "Private IP addresses of all Redis cluster nodes"
  value       = azurerm_linux_virtual_machine.nodes[*].private_ip_address
}