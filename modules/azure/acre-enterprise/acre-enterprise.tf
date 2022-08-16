# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

#resource "azurerm_resource_group_template_deployment" "acre-template" {
#  name                  = "${var.name}-tamplate"
#  resource_group_name   = var.resource_group
#  deployment_mode       = "Incremental"
#  template_content      = templatefile("${path.module}/templates/create_acre_enterprise.json",
#    {
#      acre_name            = var.name,
#      location             = var.region,
#      acre_sku             = var.sku,
#      acre_capacity        = var.capacity,
#      resource_group_name  = var.resource_group
#  })
#}


resource "azurerm_redis_enterprise_cluster" "acre-enterprise" {
  name                = "${var.name}"
  resource_group_name = var.resource_group
  location            = var.region
  sku_name            = var.sku_name
  zones               = var.availability_zones
}

resource "azurerm_redis_enterprise_database" "default" {
  name                = "default"
  cluster_id          = azurerm_redis_enterprise_cluster.acre-enterprise.id
  client_protocol     = "Plaintext" #or Encrypted if SSL connection is required
  clustering_policy   = "EnterpriseCluster"
  eviction_policy     = "NoEviction"
  port                = var.port
  
}