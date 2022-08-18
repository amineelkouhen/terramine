variable "deployment_name" {
  description = "Deployment Name"
  # No default
  # Use CLI or interactive input.
}

variable "project" {
  default = "central-beach-194106"
}

variable "region_name" {
  default = "europe-west1"
}

variable "rack_aware" {
  default = true
}

variable "subnets" {
  type = map
  default = {
    europe-west1-b = "10.1.1.0/24",
    europe-west1-c = "10.1.2.0/24",
    europe-west1-d = "10.1.3.0/24"
  }
}

variable "private_conf" {
  default = false
}

variable "client_enabled" {
    // When a private configuration is enabled, this flag should be enabled !
  default = true
}

variable "bastion_subnet" {
  type = map
  default = {
    europe-west1-c = "10.1.4.0/24"
  }
}

# Packages to install in the client machine
variable "memtier_package" {
  description = "Memtier package URI"
  default = "https://github.com/RedisLabs/memtier_benchmark/archive/refs/tags/1.4.0.tar.gz"
}

variable "redis_stack_package" {
  description = "Redis Stack package URI"
  default = "https://redismodules.s3.amazonaws.com/redis-stack/redis-stack-server-6.2.4-v1.bionic.x86_64.tar.gz"
}

variable "promethus_package" {
  description = "Prometheus package URI"
  default = "https://github.com/prometheus/prometheus/releases/download/v2.37.0/prometheus-2.37.0.linux-amd64.tar.gz"
}

variable "credentials" {
  description = "GCP credentials file"
  default = "terraform_account.json"
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

variable "env" {
  default = "dev"
}

variable "rs_user" {
  default = "admin@admin.com"
}

variable "rs_password" {
  default = "admin"
}

// RS DNS and cluster will be
// cluster.<env>-<project_name>.demo.redislabs.com
// node1.cluster.<env>-<project_name>.demo.redislabs.com
// node2.cluster.<env>-<project_name>.demo.redislabs.com
// node3.cluster.<env>-<project_name>.demo.redislabs.com
variable "hosted_zone" {
  default = "demo.redislabs.com"
}

variable "hosted_zone_name" {
  default = "demo-clusters"
}