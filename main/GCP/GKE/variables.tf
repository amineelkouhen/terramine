variable "deployment_name" {
  description = "Deployment Name"
  # No default
  # Use CLI or interactive input.
}

variable "project" {
  default = "central-beach-194106"
}

variable "region_name" {
  default = "europe-west1"
}

variable "namespace" {
  default = "redis-enterprise-namespace"
}

variable "primary_subnet" {
  default =  "10.1.1.0/24"
}

variable "credentials" {
  description = "GCP credentials file"
  default = "terraform_account.json"
  sensitive = true
}

// other optional edits *************************************
variable "cluster_size" {
  # Since we setup a regional cluster, there will be 3 nodes in the node pool, one in each availability zone
  default = 1
}

variable "machine_type" {
  default = "e2-standard-4"
}

variable "env" {
  default = "dev"
}