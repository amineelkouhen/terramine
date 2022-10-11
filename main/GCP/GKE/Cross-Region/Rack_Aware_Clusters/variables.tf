variable "deployment_name" {
  description = "Deployment Name"
  # No default
  # Use CLI or interactive input.
}

variable "project_1" {
  default = "central-beach-194106"
}

variable "project_2" {
  default = "central-beach-194106"
}

variable "region_1_name" {
  default = "europe-west1"
}

variable "region_2_name" {
  default = "us-central1"
}

variable "namespace1" {
  default = "redis-europe-namespace"
}

variable "namespace2" {
  default = "redis-us-namespace"
}

variable "primary_subnet_1" {
  default =  "10.1.1.0/24"
}

variable "primary_subnet_2" {
  default =  "10.1.2.0/24"
}

variable "credentials_1" {
  description = "GCP credentials file"
  default = "terraform_account.json"
  sensitive = true
}

variable "credentials_2" {
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
  default = "e2-standard-8"
}

variable "env1" {
  default = "europe"
}

variable "env2" {
  default = "us"
}