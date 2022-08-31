terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

resource "google_compute_address" "bastion-ip-address" {
  name  = "${var.name}-bastion-ip-address"
}

resource "google_compute_instance" "bastion" {
  name         = "${var.name}-bastion"
  machine_type = var.machine_type
  zone         = var.availability_zone

  #can_ip_forward  = true

  boot_disk {
    initialize_params {
      image = var.machine_image
      size  = var.boot_disk_size
    }
  }

  network_interface {
    subnetwork = var.subnet

    access_config {
      nat_ip  = google_compute_address.bastion-ip-address.address
    }
  }

  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }

  metadata_startup_script = templatefile("${path.module}/scripts/prepare_client.sh", {
      ssh_user              = var.ssh_user
      memtier_package       = var.memtier_package
      redis_stack_package   = var.redis_stack_package
      promethus_package     = var.promethus_package
      redis_insight_package = var.redis_insight_package
      cluster_dns           = var.cluster_dns
  })
}