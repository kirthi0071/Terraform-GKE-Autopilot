output "cluster_name" {
  description = "GKE Autopilot cluster name"
  value       = module.gke.cluster_name
}

output "cluster_id" {
  description = "GKE Autopilot cluster ID"
  value       = module.gke.cluster_id
}

output "cluster_endpoint" {
  description = "GKE Autopilot cluster control plane endpoint"
  value       = module.gke.endpoint
  sensitive   = true
}

output "location" {
  description = "Cluster location (region)"
  value       = module.gke.location
}
