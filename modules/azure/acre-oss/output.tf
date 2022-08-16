output "hostname" {
  value = azurerm_redis_cache.redis.hostname
}

output "ssl_port" {
  value = azurerm_redis_cache.redis.ssl_port
}

output "primary_access_key" {
  value = nonsensitive(azurerm_redis_cache.redis.primary_access_key)
}

output "primary_connection_string" {
  value = nonsensitive(azurerm_redis_cache.redis.primary_connection_string)
}

output "redis_configuration" {
  value = azurerm_redis_cache.redis.redis_configuration
}