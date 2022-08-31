output "public-ip" {
  value = google_compute_address.bastion-ip-address.address
}

output "prometheus-endpoint" {
  value = "http://${google_compute_address.bastion-ip-address.address}:9090"
}

output "grafana-endpoint" {
  value = "http://${google_compute_address.bastion-ip-address.address}:3000"
}

output "redis-insight-endpoint" {
  value = "http://${google_compute_address.bastion-ip-address.address}:8001"
}