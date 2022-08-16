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

variable "sku_name" {
  description = "The sku_name is comprised of two segments separated by a hyphen (e.g. Enterprise_E10-2). The first segment of the sku_name defines the name of the SKU, possible values are Enterprise_E10, Enterprise_E20, Enterprise_E50, Enterprise_E100, EnterpriseFlash_F300, EnterpriseFlash_F700 or EnterpriseFlash_F1500. The second segment defines the capacity of the sku_name, possible values for Enteprise SKUs are (2, 4, 6, …). Possible values for EnterpriseFlash SKUs are (3, 9, 15, …)."
  type        = string
}

variable "availability_zones" {
  description = "Specifies a list of Availability Zones in which this Redis Cache should be located."
  type        = list
}

variable "port" {
  description = "The exposed port."
  type        = number
}