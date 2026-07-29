variable "project_id" {
  description = "Project ID where the GKE Autopilot cluster will be created"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE Autopilot cluster"
  type        = string
}

variable "region" {
  description = "Region for the regional Autopilot cluster"
  type        = string
}

variable "network_self_link" {
  description = "Self link of the VPC the cluster attaches to (from the network module)"
  type        = string
}

variable "subnetwork_self_link" {
  description = "Self link of the subnet the cluster's nodes/control plane attach to (from the network module)"
  type        = string
}

variable "pods_range_name" {
  description = "Name of the secondary range used for Pod IPs (must exist on the subnet via secondary_ranges)"
  type        = string
}

variable "services_range_name" {
  description = "Name of the secondary range used for Service IPs (must exist on the subnet via secondary_ranges)"
  type        = string
}

variable "master_authorized_networks" {
  description = "List of CIDR blocks allowed to reach the cluster's control plane"
  type = list(object({
    display_name = string
    cidr_block   = string
  }))
}

variable "workload_pool" {
  description = "Workload Identity pool, normally '<project_id>.svc.id.goog'"
  type        = string
}

variable "release_channel" {
  description = "GKE release channel: RAPID, REGULAR, or STABLE"
  type        = string
  default     = "REGULAR"
}

variable "deletion_protection" {
  description = "Whether to block terraform destroy from deleting the cluster"
  type        = bool
  default     = false
}

variable "resource_labels" {
  description = "Labels to apply to the cluster"
  type        = map(string)
  default     = {}
}
