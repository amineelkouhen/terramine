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

variable "public_subnets_cidrs" {
  description = "CIDR block for the public subnets"
  type        = map
}

variable "private_subnets_cidrs" {
  description = "CIDR block for the private subnets"
  type        = map
}
