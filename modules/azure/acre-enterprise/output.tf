output "cluster" {
  value = azurerm_redis_enterprise_cluster.acre-enterprise
}

output "hostname" {
  value = azurerm_redis_enterprise_cluster.acre-enterprise.hostname
}

output "primary_access_key" {
  value = nonsensitive(azurerm_redis_enterprise_database.default.primary_access_key)
}