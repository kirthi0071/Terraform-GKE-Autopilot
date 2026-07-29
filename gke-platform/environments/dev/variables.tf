# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
variable "project_id" {
  description = "GCP project ID to deploy into"
  type        = string
}

variable "region" {
  description = "Primary region for network, subnets, and the GKE cluster"
  type        = string
}

variable "env" {
  description = "Environment short name, used in resource naming/labels (e.g. dev, uat, prod)"
  type        = string
}

# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------
variable "network_name" {
  description = "Name of the VPC to create"
  type        = string
}

variable "subnets" {
  description = "List of subnets to create in the VPC"
  type = list(object({
    subnet_name           = string
    subnet_ip              = string
    subnet_region          = string
    subnet_private_access  = optional(string, "true")
    subnet_flow_logs       = optional(string, "false")
    description            = optional(string)
  }))
}

variable "secondary_ranges" {
  description = "Map keyed by subnet_name of secondary IP ranges, used for GKE pod/service ranges"
  type = map(list(object({
    range_name    = string
    ip_cidr_range = string
  })))
}

variable "gke_subnet_name" {
  description = "Which entry in var.subnets the GKE cluster should attach to"
  type        = string
}

variable "gke_pods_range_name" {
  description = "range_name (within secondary_ranges for gke_subnet_name) to use for Pod IPs"
  type        = string
}

variable "gke_services_range_name" {
  description = "range_name (within secondary_ranges for gke_subnet_name) to use for Service IPs"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress firewall rules"
  type = list(object({
    name           = string
    description    = optional(string)
    priority       = optional(number)
    source_ranges  = optional(list(string), [])
    source_tags    = optional(list(string))
    target_tags    = optional(list(string))
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress firewall rules"
  type = list(object({
    name               = string
    description        = optional(string)
    priority           = optional(number)
    destination_ranges = optional(list(string), [])
    target_tags        = optional(list(string))
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
  }))
  default = []
}

# -----------------------------------------------------------------------------
# IAM
# -----------------------------------------------------------------------------
variable "gke_service_account_id" {
  description = "Account ID for the GKE node/workload service account"
  type        = string
  default     = "gke-node-sa"
}

variable "sa_bindings" {
  description = "Map of role => members to bind directly on the GKE service account (e.g. workload identity user)"
  type        = map(list(string))
  default     = {}
}

# -----------------------------------------------------------------------------
# GKE
# -----------------------------------------------------------------------------
variable "cluster_name" {
  description = "Name of the GKE Autopilot cluster"
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
