variable "project_id" {
  description = "Project ID where the service account will be created"
  type        = string
}

variable "service_account_id" {
  description = "Account ID for the service account"
  type        = string
}

variable "service_account_display_name" {
  description = "Display name for the service account"
  type        = string
}

variable "mode" {
  description = "IAM binding mode ('additive' or 'authoritative')"
  type        = string
  default     = "additive"
}

variable "project_roles" {
  description = "List of project-level IAM roles to grant"
  type        = list(string)
  default     = []
}

variable "bindings" {
  description = "Map of role => list of members to bind on the service account"
  type        = map(list(string))
  default     = {}
}
