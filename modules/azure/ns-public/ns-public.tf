# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

data "azurerm_dns_zone" "hosted_zone" {
  name                = "${var.hosted_zone}"
  resource_group_name = "SA_Group"
}

resource "azurerm_dns_a_record" "A-records" {
  zone_name           = data.azurerm_dns_zone.hosted_zone.name
  resource_group_name = "SA_Group"
  tags                = "${var.resource_tags}"
  name                = replace("node${count.index+1}.cluster.${var.subdomain}.${var.hosted_zone}", ".${data.azurerm_dns_zone.hosted_zone.name}", "")
  ttl                 = 60
  records             = [ tostring(var.ip_addresses[count.index]) ]
  count               = length(var.ip_addresses)
}

resource "azurerm_dns_ns_record" "NS-record" {
  zone_name           = data.azurerm_dns_zone.hosted_zone.name
  resource_group_name = "SA_Group"
  tags                = "${var.resource_tags}"
  name                = replace("cluster.${var.subdomain}.${var.hosted_zone}", ".${data.azurerm_dns_zone.hosted_zone.name}", "")
  ttl                 = 60
  records             = formatlist("%s.${var.hosted_zone}", tolist(azurerm_dns_a_record.A-records.*.name))
}