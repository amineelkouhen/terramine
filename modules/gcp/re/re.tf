terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

#resource "google_compute_address" "cluster-ip-address" {
#  name  = "${var.name}-${count.index}-cluster-ip-address"
#  count = var.kube_worker_machine_count
#}

resource "google_compute_instance" "cluster_master" {
  name            = "${var.name}-node-0"
  machine_type    = var.machine_type
  zone            = var.availability_zones[0]
  can_ip_forward  = true

  boot_disk {
    initialize_params {
      image = var.machine_image
      size  = var.boot_disk_size
    }
  }

  network_interface {
    subnetwork = var.subnets[0].id
    access_config {
          // Ephemeral IP
    }
#    access_config {
#      nat_ip  = google_compute_address.cluster-ip-address[count.index].address
#    }
  }

  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }

  metadata_startup_script = templatefile("${path.module}/scripts/install_create_rs_cluster.sh", {
      ssh_user          = var.ssh_user
      redis_distro      = var.redis_distro
      node_id           = 1
      rack_aware        = var.rack_aware
      cluster_dns       = var.cluster_dns
      redis_user        = var.redis_user
      redis_password    = var.redis_password
      availability_zone = var.availability_zones[0]
      node_1_ip         = ""
  })
}

resource "google_compute_instance" "nodes" {
  count           = (var.worker_count > 1)? var.worker_count - 1 : 0
  name            = "${var.name}-node-${count.index + 1}"
  machine_type    = var.machine_type
  zone            = var.availability_zones[(count.index + 1) % length(var.availability_zones)]
  can_ip_forward  = true

  boot_disk {
    initialize_params {
      image = var.machine_image
      size  = var.boot_disk_size
    }
  }

  network_interface {
    subnetwork = var.subnets[(count.index + 1) % length(var.availability_zones)].id
    access_config {
          // Ephemeral IP
    }
#    access_config {
#      nat_ip  = google_compute_address.cluster-ip-address[count.index].address
#    }
  }

  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }

  metadata_startup_script = templatefile("${path.module}/scripts/install_create_rs_cluster.sh", {
      ssh_user = var.ssh_user
      redis_distro = var.redis_distro
      node_id  = count.index + 2
      rack_aware = var.rack_aware
      cluster_dns = var.cluster_dns
      redis_user = var.redis_user
      redis_password = var.redis_password
      availability_zone = var.availability_zones[(count.index + 1) % length(var.availability_zones)]
      node_1_ip = google_compute_instance.cluster_master.network_interface.0.network_ip
  })

  
}