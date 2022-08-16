variable "name" {
  description = "Project name, also used as prefix for resources"
  type        = string
}

variable "peer_vnet" {
  description = "The VNET with which you are creating the VNET Peering Connection"
}

variable "requester_vnet" {
  description = "The requester VNET"
}

variable "resource_group" {
  description = "Azure resourcegroup for the deployment"
  type        = string
}