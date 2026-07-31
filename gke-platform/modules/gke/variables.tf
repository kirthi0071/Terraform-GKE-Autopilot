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

variable "node_service_account_email" {
  description = "Email of the service account Autopilot nodes should run as (from the iam module/root)"
  type        = string
}

# NOTE: these two must never be left as `null`. The upstream
# gke-autopilot-cluster module's own defaults ARE null, but its variable
# validation blocks do `var.x == null || contains([...], var.x)` - HCL
# evaluates both sides of `||` before combining them, so contains() still
# gets called with a null argument and errors out during `terraform
# validate`/`plan`, even though the `== null` branch is true. Always pass
# an explicit accepted value instead of relying on the module's default.
variable "datapath_provider" {
  description = "Datapath provider for the cluster. Autopilot requires Dataplane v2 (ADVANCED_DATAPATH)."
  type        = string
  default     = "ADVANCED_DATAPATH"
}

variable "private_ipv6_google_access" {
  description = "Private IPv6 access to Google services. Disabled unless you specifically need IPv6."
  type        = string
  default     = "PRIVATE_IPV6_GOOGLE_ACCESS_DISABLED"
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
