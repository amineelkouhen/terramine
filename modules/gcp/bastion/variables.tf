variable "name" {
  description = "Project name, also used as prefix for resources"
  type        = string
}

variable "resource_tags" {
  description = "hash with tags for all resources"
}

variable "availability_zone" {
  description = "Default availability zone"
  type        = string
}

variable "subnet" {
  description = "Id of the subnet, to which this bastion belongs"
  type        = string
}

variable "machine_image" {
  description = "VM image"
  type        = string
}

variable "machine_type" {
  description = "VM type"
  type        = string
}

variable "ssh_user" {
  description = "SSH linux user"
  type        = string
}

variable "ssh_public_key" {
  description = "Path to SSH public key"
  type        = string
}

variable "boot_disk_size" {
  description = "Volume Size"
  type        = number
}

variable "memtier_package" {
  description = "Memtier package URI"
  type        = string
}

variable "redis_stack_package" {
  description = "Redis Stack package URI"
  type        = string
}

variable "promethus_package" {
  description = "Prometheus package URI"
  type        = string
}

variable "redis_insight_package" {
  description = "Redis Insight package URI"
  type        = string
}

variable "cluster_dns" {
  description = "Redis Cluster FQDN"
  type        = string
}