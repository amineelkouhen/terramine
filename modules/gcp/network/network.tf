terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

resource "google_compute_network" "vpc" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

################################   ##subnet and route ##########################

resource "google_compute_subnetwork" "public-subnets" {
  count = length(var.public_subnets_cidrs)
  name          = "${var.name}-public-subnet-${count.index}"
  network       = google_compute_network.vpc.name
  ip_cidr_range = values(var.public_subnets_cidrs)[count.index]
  region        = var.region
}

resource "google_compute_subnetwork" "private-subnets" {
  count = length(var.private_subnets_cidrs)
  name          = "${var.name}-private-subnet-${count.index}"
  network       = google_compute_network.vpc.name
  ip_cidr_range = values(var.private_subnets_cidrs)[count.index]
  region        = var.region
}

resource "google_compute_router" "router" {
  count = length(var.private_subnets_cidrs)
  name    = "${var.name}-router-${count.index}"
  region  = google_compute_subnetwork.private-subnets[count.index].region
  network = google_compute_network.vpc.self_link
  bgp {
    asn = 64514
  }
}

################################ nat  ############################

resource "google_compute_router_nat" "simple-nat" {
  count = length(var.private_subnets_cidrs)
  name                               = "${var.name}-nat-${count.index}"
  router                             = google_compute_router.router[count.index].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}


################################ firewall ############################


resource "google_compute_firewall" "allow-local" {
  name    = "${var.name}-firewall-allow-local"
  description = "Allow inbound traffic from local VPC"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "tcp"
     ports    = ["0-65535"]
  }

  allow {
    protocol = "ipip"
  }

  source_ranges = concat( values(var.public_subnets_cidrs), values(var.private_subnets_cidrs))
}

resource "google_compute_firewall" "allow-global" {
  name    = "${var.name}-firewall-allow-global"
  description = "Allow inbound traffic from global VPC"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "udp"
    ports    = ["53", "5353"]
  }
  
  allow {
    protocol = "tcp"
    ports    = ["53", "5353"]
  }

  allow {
    protocol = "tcp"
    ports    = ["10000-19999", "21", "80", "443", "3000", "8443", "8001", "8070", "8071", "9081", "9090", "9443", "8080"]
  }

  source_ranges = [ "0.0.0.0/0" ]
}
