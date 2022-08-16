# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

resource "azurerm_virtual_network_peering" "peering" {
  name                      = "${var.name}-peering"
  resource_group_name       = var.resource_group
  virtual_network_name      = var.requester_vnet.name
  remote_virtual_network_id = var.peer_vnet.id
}