output "service_account_email" {
  description = "The email of the GKE service account"
  value       = google_service_account.gke_sa.email
}

output "service_account_id" {
  description = "Fully qualified ID of the GKE service account"
  value       = google_service_account.gke_sa.id
}
