variable "deployment_name" {
  description = "Deployment Name"
  # No default
  # Use CLI or interactive input.
}

variable "region_1_name" {
  default = "us-east-1"
}

variable "vpc_1_cidr" {
  default = "10.1.0.0/16"
}

variable "subnets_1" {
  type = map
  default = {
    us-east-1a = "10.1.1.0/24"
    us-east-1b = "10.1.2.0/24"
    us-east-1c = "10.1.3.0/24"
  }
}

variable "client_1_enabled" {
  // When a private configuration is enabled, this flag should be enabled !
  default = true
}

variable "bastion_1_subnet" {
  type = map
  default = {
    us-east-1a = "10.1.4.0/24"
  }
}

variable "region_2_name" {
  default = "us-west-2"
}

variable "vpc_2_cidr" {
  default = "10.2.0.0/16"
}

variable "subnets_2" {
  type = map
  default = {
    us-west-2a = "10.2.1.0/24"
    us-west-2b = "10.2.2.0/24"
    us-west-2c = "10.2.3.0/24"
  }
}

variable "client_2_enabled" {
  // When a private configuration is enabled, this flag should be enabled !
  default = true
}

variable "bastion_2_subnet" {
  type = map
  default = {
    us-west-2a = "10.2.4.0/24"
  }
}

variable "rack_aware" {
  default = true
}

variable "private_conf" {
  default = false
}

variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_user" {
  default = "ubuntu"
}

variable "volume_size" {
  default = 200
}

variable "volume_type" {
  default = "gp3"
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
  default = "https://redismodules.s3.amazonaws.com/redis-stack/redis-stack-server-6.2.4-v1.bionic.x86_64.tar.gz"
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
  default = "t2.2xlarge"
}

variable "machine_image_region_1" {
  // Ubuntu 20.04 LTS
  default = "ami-0261755bbcb8c4a84"
}

variable "machine_image_region_2" {
  // Ubuntu 20.04 LTS
  default = "ami-0c65adc9a5c1b5d7c"
}

variable "env1" {
  default = "east"
}

variable "env2" {
  default = "west"
}

variable "rs_user" {
  default = "admin@admin.com"
}

variable "rs_password" {
  default = "admin"
}

// RS DNS and cluster will be
// cluster.<envX>-<project_name>.demo-rlec.redislabs.com
// node1.cluster.<envX>-<project_name>.demo-rlec.redislabs.com
// node2.cluster.<envX>-<project_name>.demo-rlec.redislabs.com
// node3.cluster.<envX>-<project_name>.demo-rlec.redislabs.com
variable "hosted_zone" {
  default = "demo-rlec.redislabs.com"
}