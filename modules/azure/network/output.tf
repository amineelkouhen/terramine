output "vnet" {
  description = "The id of the Azure virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "raw_vnet" {
  description = "The Azure virtual network"
  value       = azurerm_virtual_network.vnet
}

output "subnets" {
  description = "The created subnets"
  value       = var.private_conf ? azurerm_subnet.private-subnets[*].id  : azurerm_subnet.public-subnets[*].id
}

output "bastion-subnet" {
  description = "The bastion subnet"
  value       = azurerm_subnet.bastion-public-subnet
}

output "security-groups" {
  description = "The ids of security groups"
  value       = var.private_conf ? [azurerm_network_security_group.allow-local.id] : [azurerm_network_security_group.allow-global.id, azurerm_network_security_group.allow-local.id]
}

output "bastion-security-groups" {
  description = "The ids of the bastion security groups"
  value       = [azurerm_network_security_group.allow-global.id]
}