output "vpc" {
  description = "The id of the VPC"
  value       = google_compute_network.vpc.id 
}

output "raw_vpc" {
  description = "The the VPC"
  value       = google_compute_network.vpc 
}

output "private-subnets" {
  description = "The private subnets"
  value       = google_compute_subnetwork.private-subnets
}

output "public-subnets" {
  description = "The public subnets"
  value       = google_compute_subnetwork.public-subnets
}