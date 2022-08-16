variable "name" {
  description = "Project name, also used as prefix for resources"
  type        = string
}

variable "resource_tags" {
  description = "hash with tags for all resources"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
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

variable "bastion_subnet_cidr" {
  description = "The availbaility zone with the subnet cidr, in which this bastion will be created"
  type        = map
}
