resource "google_compute_network_peering" "peering" {
  name         = "${var.name}-peering"
  network      = var.requester_vpc.self_link
  peer_network = var.peer_vpc.self_link
}