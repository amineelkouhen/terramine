output "peering" {
  description = "The id of the Peering"
  value       = google_compute_network_peering.peering.id 
}
