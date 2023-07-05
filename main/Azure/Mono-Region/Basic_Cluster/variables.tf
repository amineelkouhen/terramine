variable "deployment_name" {
  description = "Deployment Name"
  # No default
  # Use CLI or interactive input.
}

variable "region_name" {
  default = "East US"
}

variable "vnet_cidr" {
  default = "10.1.0.0/16"
}

variable "rack_aware" {
  default = false
}

variable "subnets" {
  type = map
  default = {
    1 = "10.1.1.0/24"
  }
}

variable "private_conf" {
  default = false
}

variable "client_enabled" {
  default = true
}

variable "bastion_subnet" {
  type = map
  default = {
    1 = "10.1.4.0/24"
  }
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

variable "azure_access_key_id" {
  description = "Azure Access Key ID (Application ID)"
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
}

variable "azure_secret_key" {
  description = "Azure Secret Key"
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

variable "volume_type" {
  default = "Premium_LRS"
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

variable "machine_type" {
  default = "Standard_D2s_v3"
}

variable "machine_image" {
  // Ubuntu 20.04 LTS
  default = "Canonical:UbuntuServer:20.04-LTS:latest"
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
// cluster.<env>-<project_name>.demo-azure.redislabs.com
// node1.cluster.<env>-<project_name>.demo-azure.redislabs.com
// node2.cluster.<env>-<project_name>.demo-azure.redislabs.com
// node3.cluster.<env>-<project_name>.demo-azure.redislabs.com
variable "hosted_zone" {
  default = "demo-azure.redislabs.com"
}