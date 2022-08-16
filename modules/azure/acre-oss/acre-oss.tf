# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "redis" {
  name                          = var.name
  location                      = var.region
  resource_group_name           = var.resource_group
  capacity                      = var.capacity
  family                        = var.family
  sku_name                      = var.sku
  shard_count                   = var.shard_count
  redis_version                 = 6
  zones                         = var.availability_zones
  enable_non_ssl_port           = true

  tags = {
    name = "${var.name}-acre"
  }
    
  redis_configuration {
    enable_authentication = true
    maxmemory_reserved = 200
    maxmemory_delta    = 200
    maxmemory_policy   = "volatile-lru"
  }
}