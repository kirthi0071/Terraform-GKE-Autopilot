output "cluster_id" {
  description = "GKE cluster ID"
  value       = google_container_cluster.gke_autopilot.id
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.gke_autopilot.name
}

output "endpoint" {
  description = "GKE control plane endpoint"
  value       = google_container_cluster.gke_autopilot.endpoint
  sensitive   = true
}

output "location" {
  description = "Cluster location (region)"
  value       = google_container_cluster.gke_autopilot.location
}
