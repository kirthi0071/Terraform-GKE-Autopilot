resource "google_service_account" "gke_sa" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}

resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset(var.project_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

module "service_accounts_iam" {
  source  = "terraform-google-modules/iam/google//modules/service_accounts_iam"
  version = "~> 8.0"

  project          = var.project_id
  service_accounts = [google_service_account.gke_sa.email]
  mode             = var.mode
  bindings         = var.bindings

  depends_on = [google_service_account.gke_sa]
}
