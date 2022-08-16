variable "name" {
  description = "Project name, also used as prefix for resources"
  type        = string
}

variable "peer_vpc" {
  description = "The VPC with which you are creating the VPC Peering Connection"
}

variable "requester_vpc" {
  description = "The requester VPC"
}
