output "public-subnets" {
  description = "The ID of the public subnet"
  value       = azurerm_subnet.public-subnets[*].id
}

output "private-subnets" {
  description = "The ID of the private subnet"
  value       = azurerm_subnet.private-subnets[*].id
}

output "private_subnet_address_prefix" {
  description = "The address prefix of the private subnet"
  value       = azurerm_subnet.private-subnets[*].address_prefix
}

output "public-security-groups" {
  description = "The id of the public groups"
  value       = [azurerm_network_security_group.allow-global.id]
}

output "private-security-groups" {
  description = "The id of the private security groups"
  value       = [azurerm_network_security_group.allow-local.id]
}

output "vnet" {
  description = "The id of the Azure virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "raw_vnet" {
  description = "The Azure virtual network"
  value       = azurerm_virtual_network.vnet
}