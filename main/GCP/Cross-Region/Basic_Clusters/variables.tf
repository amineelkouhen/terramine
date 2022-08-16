variable "deployment_name" {
  description = "Deployment Name"
  # No default
  # Use CLI or interactive input.
}

variable "project_1" {
  default = "central-beach-194106"
}

variable "region_1_name" {
  default = "europe-west1"
}

variable "project_2" {
  default = "central-beach-194106"
}

variable "region_2_name" {
  default = "us-east1"
}

variable "env1" {
  default = "europe"
}

variable "env2" {
  default = "us"
}

variable "rs_private_subnets_1" {
  type = map
  default = {
    europe-west1-b = "10.1.1.0/24"
  }
}

variable "rs_public_subnets_1" {
  type = map
  default = {
    europe-west1-b = "10.1.2.0/24"
  }
}

variable "rs_private_subnets_2" {
  type = map
  default = {
    us-east1-b = "10.2.1.0/24"
  }
}

variable "rs_public_subnets_2" {
  type = map
  default = {
    us-east1-b = "10.2.2.0/24"
  }
}

variable "rack_aware" {
  default = false
}

variable "credentials_1" {
  description = "GCP credentials file for Project/Region 1"
  default = "terraform_account_1.json"
  sensitive = true
}

variable "credentials_2" {
  description = "GCP credentials file for Project/Region 2"
  default = "terraform_account_2.json"
  sensitive = true
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_user" {
  default = "ubuntu"
}

variable "volume_size" {
  default = 40
}

// other optional edits *************************************
variable "cluster_size" {
  # You should use 3 for some more realistic installation
  default = 3
}

// other possible edits *************************************
variable "rs_release" {
  default = "https://s3.amazonaws.com/redis-enterprise-software-downloads/6.2.10/redislabs-6.2.10-100-bionic-amd64.tar"
}

variable "machine_type" {
  default = "e2-standard-2"
}

variable "machine_image" {
  // Ubuntu 18.04 LTS
  default = "ubuntu-minimal-1804-lts"
}

variable "rs_user" {
  default = "admin@admin.com"
}

variable "rs_password" {
  default = "admin"
}

// RS DNS and cluster will be
// cluster.<envX>-<project_name>.demo.redislabs.com
// node1.cluster.<envX>-<project_name>.demo.redislabs.com
// node2.cluster.<envX>-<project_name>.demo.redislabs.com
// node3.cluster.<envX>-<project_name>.demo.redislabs.com
variable "hosted_zone" {
  default = "demo.redislabs.com"
}

variable "hosted_zone_name" {
  default = "demo-clusters"
}