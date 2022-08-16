variable "deployment_name" {
  description = "Deployment Name"
  # No default
  # Use CLI or interactive input.
}

variable "region_1_name" {
  default = "East US"
}

variable "vnet_1_cidr" {
  default = "10.1.0.0/16"
}

variable "rs_private_subnets_1" {
  type = map
  default = {
    1 = "10.1.1.0/24"
    2 = "10.1.2.0/24"
    3 = "10.1.3.0/24"
  }
}

variable "rs_public_subnets_1" {
  type = map
  default = {
    1 = "10.1.4.0/24"
    2 = "10.1.5.0/24"
    3 = "10.1.6.0/24"
  }
}

variable "region_2_name" {
  default = "West US 2"
}

variable "vnet_2_cidr" {
  default = "10.2.0.0/16"
}

variable "rs_private_subnets_2" {
  type = map
  default = {
    1 = "10.2.1.0/24"
    2 = "10.2.2.0/24"
    3 = "10.2.3.0/24"
  }
}

variable "rs_public_subnets_2" {
  type = map
  default = {
    1 = "10.2.4.0/24"
    2 = "10.2.5.0/24"
    3 = "10.2.6.0/24"
  }
}

variable "rack_aware" {
  default = true
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
  default = "https://s3.amazonaws.com/redis-enterprise-software-downloads/6.2.10/redislabs-6.2.10-100-bionic-amd64.tar"
}

variable "machine_type" {
  default = "Standard_D2s_v3"
}

variable "machine_image" {
  // Ubuntu 18.04 LTS
  default = "Canonical:UbuntuServer:18.04-LTS:latest"
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
// cluster.<envX>-<project_name>.demo-azure.redislabs.com
// node1.cluster.<envX>-<project_name>.demo-azure.redislabs.com
// node2.cluster.<envX>-<project_name>.demo-azure.redislabs.com
// node3.cluster.<envX>-<project_name>.demo-azure.redislabs.com
variable "hosted_zone" {
  default = "demo-azure.redislabs.com"
}