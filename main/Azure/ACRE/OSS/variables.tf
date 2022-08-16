variable "deployment_name" {
  description = "Deployment Name"
  # No default
  # Use CLI or interactive input.
}

variable "env" {
  default = "dev"
}

variable "azure_access_key_id" {
  description = "Azure Access Key ID (Application ID)"
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
}

variable "azure_secret_key" {
  description = "Azure Secret Key"
}

variable "region_name" {
  description = "Region for the ACRE instance deployment."
  default = "East US"
}

variable "capacity" {
  description = "The size of the Redis cache to deploy (number of data nodes). Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6, and for P (Premium) family are 1, 2, 3, 4."
  default = 1
}

variable "sku" {
  description = "The SKU of Redis to use. Possible values are Basic, Standard, Premium and Enterprise."
  default = "Premium"
}

variable "availability_zones" {
  description = "Specifies a list of Availability Zones in which this Redis Cache should be located."
  default     = [1, 2, 3]
}

variable "family" {
  description = "The SKU family/pricing group to use. Valid values are C (for Basic/Standard SKU family) and P (for Premium)."
  default     = "P"
}

variable "shard_count" {
  description = "Only available when using the Premium SKU The number of Shards to create on the Redis Cluster."
  default     = 2
}