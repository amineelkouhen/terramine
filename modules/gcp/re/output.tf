output "re-public-ips" {
  description = "IP addresses of all Redis cluster nodes"
  value = flatten([google_compute_instance.cluster_master.network_interface.0.access_config.0.nat_ip , flatten([google_compute_instance.nodes.*.network_interface.0.access_config.0.nat_ip])])
}