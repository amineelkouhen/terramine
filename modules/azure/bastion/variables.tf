variable "name" {
  description = "Deployment name, also used as prefix for resources: <name>-<VPC>"
  type        = string
}

variable "resource_tags" {
  description = "hash with tags for all resources"
}

variable "availability_zone" {
  description = "Default availability zone"
  type        = string
}

variable "region" {
  description = "Region for the VCP/VNET deployment"
  type        = string
}

variable "subnet" {
  description = "Id of the subnet, to which this bastion belongs"
  type        = string
}

variable "security_groups" {
  description = "List of security groups to attached to the bastion"
  type        = list(string)
}

variable "machine_image" {
  description = "Virtual machine image (OS)"
  type        = string
}

variable "machine_type" {
  description = "Hardwaretype for client nodes"
  type        = string
}

variable "resource_group" {
  description = "Azure resourcegroup for the deployment"
  type        = string
}

variable "ssh_public_key"{
  description = "Path to SSH public key"
  type        = string
} 

variable "ssh_user" {
  description = "SSH linux user"
  type        = string
}

variable "boot_disk_size" {
  description = "Volume Size"
  type        = number
}

variable "boot_disk_type" {
  description = "Volume Type"
  type        = string
}

variable "memtier_package" {
  description = "Memtier package URI"
  type        = string
}

variable "redis_stack_package" {
  description = "Redis Stack package URI"
  type        = string
}

variable "redis_insight_package" {
  description = "Redis Insight package URI"
  type        = string
}

variable "promethus_package" {
  description = "Prometheus package URI"
  type        = string
}

variable "cluster_dns" {
  description = "Redis Cluster FQDN"
  type        = string
}