variable "name" {
  description = "Name of this resource"
  type        = string
}

variable "region" {  
  description = "Region Name"
  type        = string
}

variable "resource_tags" {
  description = "hash with tags for all resources"
}

variable "subnets" {
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

variable "bastion_subnet" {
  description = "The availbaility zone with the subnet cidr, in which this bastion will be created"
  type        = map
}