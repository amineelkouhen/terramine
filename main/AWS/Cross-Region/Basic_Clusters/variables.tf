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
  }
}

variable "client_1_enabled" {
  // When a private configuration is enabled, this flag should be enabled !
  default = false
}

variable "bastion_1_subnet" {
  type = map
  default = {
    us-east-1a = "10.1.4.0/24"
  }
}

variable "region_2_name" {
  default = "us-west-1"
}

variable "vpc_2_cidr" {
  default = "10.2.0.0/16"
}

variable "subnets_2" {
  type = map
  default = {
    us-west-1a = "10.2.1.0/24"
  }
}

variable "client_2_enabled" {
  // When a private configuration is enabled, this flag should be enabled !
  default = false
}

variable "bastion_2_subnet" {
  type = map
  default = {
    us-west-1a = "10.2.4.0/24"
  }
}

variable "rack_aware" {
  default = false
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
  default = "https://s3.amazonaws.com/redis-enterprise-software-downloads/6.2.10/redislabs-6.2.10-100-bionic-amd64.tar"
}

variable "machine_type" {
  default = "t2.2xlarge"
}

variable "machine_image_region_1" {
  // Ubuntu 18.04 LTS
  default = "ami-0729e439b6769d6ab"
}

variable "machine_image_region_2" {
  // Ubuntu 18.04 LTS
  default = "ami-067f8db0a5c2309c0"
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