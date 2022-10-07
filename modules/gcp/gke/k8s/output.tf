output "cluster" {
    description = "GKE cluster's Name"
    value = google_container_cluster.primary
}