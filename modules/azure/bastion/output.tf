output "public-ip" {
  value = azurerm_public_ip.client-public-ip.ip_address
}

output "prometheus-endpoint" {
  value = "http://${azurerm_public_ip.client-public-ip.ip_address}:9090"
}

output "grafana-endpoint" {
  value = "http://${azurerm_public_ip.client-public-ip.ip_address}:3000"
}

output "redis-insight-endpoint" {
  value = "http://${azurerm_public_ip.client-public-ip.ip_address}:8001"
}