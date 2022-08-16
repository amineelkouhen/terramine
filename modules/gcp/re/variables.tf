variable "worker_count" {}
variable "machine_type" {}
variable "machine_image" {}
variable "subnets" {}
variable "ssh_user" {}
variable "ssh_public_key" {}
variable "boot_disk_size" {}
variable "name" {}
variable "rack_aware" {}
variable "cluster_dns" {}
variable "redis_distro" {}
variable "redis_user" {}
variable "redis_password" {}
variable "availability_zones" {}
variable "resource_tags" {
  description = "hash with tags for all resources"
}