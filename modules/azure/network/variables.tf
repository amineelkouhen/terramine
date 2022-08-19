variable "name" {
  description = "Name of the VNET"
  type        = string
}

variable "resource_tags" {
  description = "hash with tags for all resources"
}

variable "vnet_cidr" {
  description = "CIDR for the whole VPC/VNET"
  type        = string
}
variable "subnets_cidrs" {
  description = "CIDR blocks for the subnets in each zone"
  type        = map
}

variable "private_conf" {
  description = "flag for public configuration"
  type        = bool
}

variable "client_enabled" {
  description = "flag for client creation"
  type        = bool
}

variable "region" {
  description = "Region for the VCP/VNET deployment"
  type        = string
}

variable "resource_group" {
  description = "Azure resourcegroup for the deployment"
  type        = string
}

variable "bastion_subnet_cidr" {
  description = "The availbaility zone with the subnet cidr, in which this bastion will be created"
  type        = map
}