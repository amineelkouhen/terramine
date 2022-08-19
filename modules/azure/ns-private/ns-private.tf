# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

resource "azurerm_private_dns_zone" "hosted_zone" {
  name                = "${var.hosted_zone}"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet-dns-link" {
  name                  = "${var.subdomain}-link"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.hosted_zone.name
  virtual_network_id    = values(var.vnet_map)[0]
}

resource "azurerm_private_dns_a_record" "A-records" {
  zone_name           = azurerm_private_dns_zone.hosted_zone.name
  resource_group_name = var.resource_group
  tags                = "${var.resource_tags}"
  name                = replace("node${count.index+1}.cluster.${var.subdomain}.${var.hosted_zone}", ".${azurerm_private_dns_zone.hosted_zone.name}", "")
  ttl                 = 60
  records             = [ tostring(var.ip_addresses[count.index]) ]
  count               = length(var.ip_addresses)
}

resource "azurerm_private_dns_cname_record" "CNAME-record" {
  zone_name           = azurerm_private_dns_zone.hosted_zone.name
  resource_group_name = var.resource_group
  tags                = "${var.resource_tags}"
  name                = replace("cluster.${var.subdomain}.${var.hosted_zone}", ".${azurerm_private_dns_zone.hosted_zone.name}", "")
  ttl                 = 60
  record              = format("%s.${var.hosted_zone}", azurerm_private_dns_a_record.A-records[0].name)
}