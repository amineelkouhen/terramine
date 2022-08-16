output "public-ip" {
  value = var.client_enabled ? google_compute_address.bastion-ip-address[0].address : ""
}

output "prometheus-endpoint" {
  value = var.client_enabled ? "http://${google_compute_address.bastion-ip-address[0].address}:9090"  : ""
}

output "grafana-endpoint" {
  value = var.client_enabled ? "http://${google_compute_address.bastion-ip-address[0].address}:3000" : ""
}