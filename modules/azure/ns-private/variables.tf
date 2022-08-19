variable "subdomain" {
  description = "The DNS custom subdomain"
  type        = string
}

variable "hosted_zone" {
  description = "Hosted Zone where the record will be added"
  type        = string
}

variable "ip_addresses" {
  description = "List of Public (!) IP addresses for each cluster node"
  type        = list
}

variable "resource_tags" {
  description = "hash with tags for all resources"
}

variable "resource_group" {
  description = "Azure resourcegroup for the deployment"
  type        = string
}

variable "vnet_map" {
  description = "The VNET map by region" 
  type        = map
}