variable "worker_count" {}

variable "machine_type" {
  description = "VM type"
  type        = string
}

variable "machine_image" {
  description = "VM image"
  type        = string
}

variable "subnets" {
  description = "list of subnets"
  type        = list
}

variable "ssh_user" {
  description = "SSH linux user"
  type        = string
}

variable "ssh_public_key" {}

variable "boot_disk_size" {
  description = "Volume Size"
  type        = number
}

variable "name" {
  description = "Deployment name, also used as prefix for resources"
  type        = string
}

variable "rack_aware" {
  description = "Rack AZ Awareness"
  type        = bool
}

variable "cluster_dns" {
  description = "Redis Cluster DNS"
  type        = string
}

variable "redis_distro" {
  description = "Redis distribution"
  type        = string
}

variable "redis_user" {
  description = "Redis Cluster Admin User"
  type        = string
}

variable "redis_password" {
  description = "Redis Cluster Admin Password"
  type        = string
  sensitive   = true
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "resource_tags" {
  description = "hash with tags for all resources"
}

variable "private_conf" {
  description = "Flag of private configuration"
  type        = bool
}