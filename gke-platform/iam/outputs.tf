output "service_account_email" {
  description = "Email of the GKE node/workload service account, consumed by the gke/ root module via remote state"
  value       = google_service_account.gke_sa.email
}

output "service_account_id" {
  description = "Fully qualified ID of the GKE service account"
  value       = google_service_account.gke_sa.id
}
