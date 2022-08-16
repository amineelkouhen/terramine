variable "name" {
  description = "Deployment name, also used as prefix for resources: <name>-<env>"
  type        = string
}

variable "region" {
  description = "Region for the ACRE deployment."
  type        = string
}

variable "resource_group" {
  description = "Azure resourcegroup for the deployment."
  type        = string
}

variable "capacity" {
  description = "The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6, and for P (Premium) family are 1, 2, 3, 4."
  type        = number
}

variable "family" {
  description = "The SKU family/pricing group to use. Valid values are C (for Basic/Standard SKU family) and P (for Premium)."
  type        = string
}

variable "sku" {
  description = "The SKU of Redis to use. Possible values are Basic, Standard and Premium."
  type        = string
}

variable "shard_count" {
  description = "Only available when using the Premium SKU The number of Shards to create on the Redis Cluster."
  type        = number 
}

variable "availability_zones" {
  description = "Specifies a list of Availability Zones in which this Redis Cache should be located."
  type        = list(string)
}