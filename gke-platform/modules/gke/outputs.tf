output "cluster_id" {
  description = "GKE cluster ID"
  value       = module.gke_autopilot.cluster_id
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke_autopilot.cluster_name
}

output "endpoint" {
  description = "GKE control plane endpoint"
  value       = module.gke_autopilot.endpoint
  sensitive   = true
}

output "location" {
  description = "Cluster location (region)"
  value       = module.gke_autopilot.location
}
