variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-south1"
}

variable "service_account_id" {
  description = "Account ID for the service account"
  type        = string
}

variable "service_account_display_name" {
  description = "Display name for the service account"
  type        = string
}

variable "project_roles" {
  description = "Project roles for the service account"
  type        = list(string)
}

variable "mode" {
  description = "IAM binding mode"
  type        = string
  default     = "additive"
}

variable "sa_bindings" {
  description = "IAM bindings ON the service account"
  type        = map(list(string))
  default     = {}
}
