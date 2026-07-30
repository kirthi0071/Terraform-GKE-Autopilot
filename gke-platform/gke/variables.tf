# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for the regional Autopilot cluster"
  type        = string
}

# -----------------------------------------------------------------------------
# Remote state pointers - tell this root module WHERE to read the vpc/ and
# iam/ root modules' state from, so it can pull their outputs.
# -----------------------------------------------------------------------------
variable "vpc_state_bucket" {
  description = "GCS bucket holding the vpc/ root module's state"
  type        = string
}

variable "vpc_state_prefix" {
  description = "GCS prefix holding the vpc/ root module's state"
  type        = string
}

variable "iam_state_bucket" {
  description = "GCS bucket holding the iam/ root module's state"
  type        = string
}

variable "iam_state_prefix" {
  description = "GCS prefix holding the iam/ root module's state"
  type        = string
}

# -----------------------------------------------------------------------------
# GKE
# -----------------------------------------------------------------------------
variable "cluster_name" {
  description = "Name of the GKE Autopilot cluster"
  type        = string
}

variable "gke_subnet_name" {
  description = "Which subnet (created by vpc/) the GKE cluster should attach to"
  type        = string
}

variable "gke_pods_range_name" {
  description = "Secondary range name (created by vpc/) to use for Pod IPs"
  type        = string
}

variable "gke_services_range_name" {
  description = "Secondary range name (created by vpc/) to use for Service IPs"
  type        = string
}

variable "master_authorized_networks" {
  description = "CIDR blocks allowed to reach the cluster control plane"
  type = list(object({
    display_name = string
    cidr_block   = string
  }))
}

variable "release_channel" {
  description = "GKE release channel"
  type        = string
  default     = "REGULAR"
}

variable "deletion_protection" {
  description = "Block terraform destroy from deleting the cluster"
  type        = bool
  default     = false
}

variable "resource_labels" {
  description = "Labels applied to the GKE cluster"
  type        = map(string)
  default     = {}
}
