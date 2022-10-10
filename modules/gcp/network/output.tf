output "vpc" {
  description = "The id of the VPC"
  value       = google_compute_network.vpc.id 
}

output "raw_vpc" {
  description = "The raw VPC"
  value       = google_compute_network.vpc 
}

output "subnets" {
  description = "The created subnets"
  value       = var.private_conf ? google_compute_subnetwork.private-subnets  : google_compute_subnetwork.public-subnets
}

output "bastion-subnet" {
  description = "The bastion subnet"
  value       = google_compute_subnetwork.bastion-public-subnet
}

output "firewall" {
  description = "The ids of firewall"
  value       = var.private_conf ? [google_compute_firewall.allow-local.id] : [google_compute_firewall.allow-global.id, google_compute_firewall.allow-local.id]
}

output "bastion-firewall" {
  description = "The ids of the bastion firewall"
  value       = [google_compute_firewall.allow-global.id, google_compute_firewall.allow-local.id]
}