output "re-nodes" {
  description = "The Redis Enterprise nodes"
  value       = azurerm_linux_virtual_machine.nodes
  sensitive   = true
}

output "re-public-ips" {
  description = "IP addresses of all Redis cluster nodes"
  value       = azurerm_public_ip.public-ips[*].ip_address
}