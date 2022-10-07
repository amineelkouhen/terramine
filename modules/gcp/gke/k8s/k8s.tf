resource "google_container_cluster" "primary" {
  name                   = "${var.name}-gke-cluster"
  location               = var.location
  network                = var.vpc
  subnetwork             = var.subnet

  # skip default node pool so keep it at minimum and remove (per docs)
  remove_default_node_pool = true
  initial_node_count       = 1

  maintenance_policy {
    daily_maintenance_window {
      start_time = "01:00"
    }
  }  
}


resource "google_container_node_pool" "node_pool" {
  name       = "${var.name}-gke-node-pool"
  cluster    = google_container_cluster.primary.name
  location   = var.location
  node_count = var.worker_count

  management {
    auto_repair   = true
    auto_upgrade  = true
  }

  node_config {
    preemptible  = false
    machine_type = var.machine_type

    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
