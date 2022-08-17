variable "name" {
  description = "Project name, also used as prefix for resources"
  type        = string
}

variable "peer_vpc" {
  description = "The VPC with which you are creating the VPC Peering Connection"
}

variable "requester_region" {
  description = "The region of the requester VPC"
  type        = string
}

variable "peer_region" {
  description = "The region of the accepter VPC of the VPC Peering Connection"
  type        = string
}

variable "requester_vpc" {
  description = "The requester VPC"
}