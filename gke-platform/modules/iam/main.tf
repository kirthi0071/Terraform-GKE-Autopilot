# -----------------------------------------------------------------------------
# Service account used by GKE Autopilot nodes / workloads
# -----------------------------------------------------------------------------
resource "google_service_account" "gke_sa" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}

# -----------------------------------------------------------------------------
# Project-level roles the SA needs to operate (logging, monitoring, pulling images)
# -----------------------------------------------------------------------------
resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset(var.project_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

# -----------------------------------------------------------------------------
# IAM policy bindings ON the service account itself (Workload Identity, etc.)
# -----------------------------------------------------------------------------
locals {
  sa_iam_bindings = flatten([
    for role, members in var.bindings : [
      for member in members : {
        role   = role
        member = member
      }
    ]
  ])
}

resource "google_service_account_iam_member" "sa_bindings" {
  for_each = {
    for b in local.sa_iam_bindings : "${b.role}-${b.member}" => b
  }

  service_account_id = google_service_account.gke_sa.name
  role               = each.value.role
  member             = each.value.member
}
