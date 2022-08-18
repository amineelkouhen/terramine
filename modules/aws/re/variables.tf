variable "name" {
  description = "Deployment name, also used as prefix for resources"
  type        = string
}

variable "subnets" {
  description = "list of subnets"
  type        = list
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security groups to attached to the node"
  type        = list(string)
}

variable "machine_image" {
  description = "AWS EC2 machine image"
  type        = string
}

variable "machine_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ssh_key_name" {
  description = "AWS EC2 Keypair's name"
  type        = string
}

variable "ssh_public_key" {
  description = "Path to SSH public key"
  type        = string
}

variable "ssh_user" {
  description = "SSH linux user"
  type        = string
}

variable "worker_count" {}

variable "resource_tags" {
  description = "hash with tags for all resources"
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

variable "cluster_dns" {
  description = "Redis Cluster DNS"
  type        = string
}

variable "rack_aware" {
  description = "Rack AZ Awareness"
  type        = bool
}

variable "boot_disk_size" {
  description = "Volume Size"
  type        = number
}

variable "boot_disk_type" {
  description = "Volume Type"
  type        = string
}

variable "private_conf" {
  description = "Flag of private configuration"
  type        = bool
}