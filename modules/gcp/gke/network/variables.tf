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

variable "primary_subnet" {
  description = "CIDR block for the primary subnet"
  type        = string
}