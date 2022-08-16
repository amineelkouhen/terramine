# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "${var.name}-vnet"
    address_space       = [ var.vnet_cidr ]
    location            = var.region
    resource_group_name = var.resource_group

    tags = {
        environment = "Terraform VPC ${var.name}-vnet"
    }
}

# Create public subnet
resource "azurerm_subnet" "public-subnets" {
    count = length(var.public_subnets_cidrs)
    name                 = "${var.name}-public-subnet-${count.index}"
    resource_group_name  = var.resource_group
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [ values(var.public_subnets_cidrs)[count.index] ]
}

# Create private subnet
resource "azurerm_subnet" "private-subnets" {
    count = length(var.private_subnets_cidrs)
    name                 = "${var.name}-private-subnet-${count.index}"
    resource_group_name  = var.resource_group
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [ values(var.public_subnets_cidrs)[count.index] ]
}

resource "azurerm_public_ip_prefix" "redis-public-prefix" {
  name                = "${var.name}-redis-public-ip-prefix"
  location            = var.region
  resource_group_name = var.resource_group
  prefix_length       = 30
}

resource "azurerm_nat_gateway" "redis-nat-gateway" {
  name                    = "${var.name}-redis-natgateway"
  location                = var.region
  resource_group_name     = var.resource_group
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "public_ip_nat_association" {
  nat_gateway_id       = azurerm_nat_gateway.redis-nat-gateway.id
  public_ip_prefix_id = azurerm_public_ip_prefix.redis-public-prefix.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet-nat-association" {
  count = length(var.private_subnets_cidrs) 
  subnet_id      = azurerm_subnet.private-subnets[count.index].id
  nat_gateway_id = azurerm_nat_gateway.redis-nat-gateway.id
  depends_on     = [azurerm_subnet.private-subnets]
}

resource "azurerm_subnet_network_security_group_association" "private-net" {
  count = length(var.private_subnets_cidrs)
  subnet_id                 = azurerm_subnet.private-subnets[count.index].id
  network_security_group_id = azurerm_network_security_group.allow-local.id
  depends_on     = [azurerm_subnet.private-subnets, azurerm_network_security_group.allow-local]
}

resource "azurerm_subnet_network_security_group_association" "public-net" {
  count = length(var.public_subnets_cidrs)
  subnet_id                 = azurerm_subnet.public-subnets[count.index].id
  network_security_group_id = azurerm_network_security_group.allow-global.id
  depends_on     = [azurerm_subnet.public-subnets, azurerm_network_security_group.allow-global]
}
