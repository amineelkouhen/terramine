output "public-ip" {
  value = var.client_enabled ? azurerm_public_ip.client-public-ip[0].ip_address : ""
}

output "prometheus-endpoint" {
  value = var.client_enabled ? "http://${azurerm_public_ip.client-public-ip[0].ip_address}:9090"  : ""
}

output "grafana-endpoint" {
  value = var.client_enabled ? "http://${azurerm_public_ip.client-public-ip[0].ip_address}:3000" : ""
}