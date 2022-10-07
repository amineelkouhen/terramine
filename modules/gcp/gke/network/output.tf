output "vpc" {
  description = "The name of the VPC"
  value       = google_compute_network.gke-vpc.name 
}

output "subnet" {
  description = "The name of the cluster's subnet"
  value       = google_compute_subnetwork.public-subnet.name 
}