variable "name" {
  description = "Deployment name, also used as prefix for resources"
  type        = string
}

variable "worker_count" {}

variable "machine_type" {
  description = "VM type"
  type        = string
}

variable "subnet" {
  description = "Subnet Name"
  type        = string
}

variable "vpc" {
  description = "VPC Name"
  type        = string
}

variable "resource_tags" {
  description = "hash with tags for all resources"
}

variable "location" {
  description = "Region/Zone Name"
  type        = string
}