variable "name" {
  description = "Deployment name, also used as prefix for resources: <name>-<VPC>"
  type        = string
}

variable "region" {
  description = "Region for the Resource Group Creation"
  type        = string
}