output "peering" {
  description = "The id of the Peering"
  value       = azurerm_virtual_network_peering.peering.id 
}