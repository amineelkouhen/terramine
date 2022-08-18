output "re-public-ips" {
  description = "Public IP addresses of all Redis cluster nodes"
  value = var.private_conf ? [] : concat(google_compute_instance.cluster_master.network_interface.0.access_config.*.nat_ip, google_compute_instance.nodes.*.network_interface.0.access_config.0.nat_ip)
}

output "re-private-ips" {
  description = "Private IP addresses of all Redis cluster nodes"
  value = flatten([google_compute_instance.cluster_master.network_interface.0.network_ip , flatten([google_compute_instance.nodes.*.network_interface.0.network_ip ])])
}