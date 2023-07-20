terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

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

  // Redis on Flash with actual infrastructure SSD local disk for NVMe
  dynamic "scratch_disk" {
    // if enabled, there will be 2 SSD mounted as RAID-0 array
    for_each = var.rof_enabled ? [1,2] : []
    content {
        interface = "NVME"
        //default size is 375 GB or function of instance type
    }
  }

  network_interface {
    subnetwork = var.subnets[0].id

    dynamic "access_config"{
       for_each = var.private_conf ? [] : [1]
       content {
          // ephemeral public IP if var.private_conf is true
       }
    }
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
      private_conf      = var.private_conf
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

  // Redis on Flash with actual infrastructure SSD local disk for NVMe
  dynamic "scratch_disk" {
    // if enabled, there will be 2 SSD mounted as RAID-0 array
    for_each = var.rof_enabled ? [1,2] : []
    content {
        interface = "NVME"
        //default size is 375 GB or function of instance type
    }
  }

  network_interface {
    subnetwork = var.subnets[(count.index + 1) % length(var.availability_zones)].id

    dynamic "access_config"{
       for_each = var.private_conf ? [] : [1]
       content {
          // ephemeral public IP if var.private_conf is true
       }
    }
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
      node_id           = count.index + 2
      rack_aware        = var.rack_aware
      cluster_dns       = var.cluster_dns
      redis_user        = var.redis_user
      redis_password    = var.redis_password
      availability_zone = var.availability_zones[(count.index + 1) % length(var.availability_zones)]
      private_conf      = var.private_conf
      node_1_ip         = google_compute_instance.cluster_master.network_interface.0.network_ip
  })  
}