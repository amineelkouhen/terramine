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
  default     = "East US"
}

variable "sku" {
  description = "The sku_name is comprised of two segments separated by a hyphen (e.g. Enterprise_E10-2). The first segment of the sku_name defines the name of the SKU, possible values are Enterprise_E10, Enterprise_E20, Enterprise_E50, Enterprise_E100, EnterpriseFlash_F300, EnterpriseFlash_F700 or EnterpriseFlash_F1500. The second segment defines the capacity of the sku_name, possible values for Enteprise SKUs are (2, 4, 6, …). Possible values for EnterpriseFlash SKUs are (3, 9, 15, …)."
  default     = "Enterprise_E10"
}

variable "availability_zones" {
  description = "Specifies a list of Availability Zones in which this Redis Cache should be located."
  default     = [1, 2, 3]
}

variable "port" {
  description = "The exposed port."
  default     = 12000
}