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

variable "private_conf" {
  default = false
}

variable "client_1_enabled" {
  // When a private configuration is enabled, this flag should be enabled !
  default = true
}

variable "subnets_1" {
  type = map
  default = {
    europe-west1-b = "10.1.1.0/24"
  }
}

variable "bastion_1_subnet" {
  type = map
  default = {
    europe-west1-c = "10.1.4.0/24"
  }
}

variable "client_2_enabled" {
  // When a private configuration is enabled, this flag should be enabled !
  default = true
}

variable "subnets_2" {
  type = map
  default = {
    us-east1-b = "10.2.1.0/24"
  }
}

variable "bastion_2_subnet" {
  type = map
  default = {
    us-east1-c = "10.2.4.0/24"
  }
}

variable "rack_aware" {
  default = false
}

variable "credentials_1" {
  description = "GCP credentials file for Project/Region 1"
  default = "terraform_account.json"
  sensitive = true
}

variable "credentials_2" {
  description = "GCP credentials file for Project/Region 2"
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
  default = "https://s3.amazonaws.com/redis-enterprise-software-downloads/6.4.2/redislabs-6.4.2-81-focal-amd64.tar"
}

# Packages to install in the client machine
variable "memtier_package" {
  description = "Memtier package URI"
  default = "https://github.com/RedisLabs/memtier_benchmark/archive/refs/tags/1.4.0.tar.gz"
}

variable "redis_stack_package" {
  description = "Redis Stack package URI"
  default = "https://redismodules.s3.amazonaws.com/redis-stack/redis-stack-server-6.2.6-v7.bionic.x86_64.tar.gz"
}

variable "promethus_package" {
  description = "Prometheus package URI"
  default = "https://github.com/prometheus/prometheus/releases/download/v2.37.0/prometheus-2.37.0.linux-amd64.tar.gz"
}

variable "redis_insight_package" {
  description = "Redis Insight package URI"
  default = "https://downloads.redisinsight.redislabs.com/1.1.0/redisinsight-linux64"
}

variable "machine_type" {
  default = "e2-standard-2"
}

variable "machine_image" {
  // Ubuntu 20.04 LTS
  default = "ubuntu-minimal-2004-lts"
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