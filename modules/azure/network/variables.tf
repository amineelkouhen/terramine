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
variable "public_subnets_cidrs" {
  description = "CIDRs for the public subnets"
  type        = map
}
variable "private_subnets_cidrs" {
  description = "CIDRs for the private subnets"
  type        = map
}

variable "region" {
  description = "Region for the VCP/VNET deployment"
  type        = string
}

variable "resource_group" {
  description = "Azure resourcegroup for the deployment"
  type        = string
}