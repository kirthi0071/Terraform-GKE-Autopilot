output "network_name" {
  description = "Name of the created VPC"
  value       = module.network.network_name
}

output "subnets_self_links" {
  description = "Map of subnet_name => self_link"
  value       = module.network.subnets_self_links
}

output "gke_service_account_email" {
  description = "Email of the GKE node/workload service account"
  value       = module.iam.service_account_email
}

output "cluster_name" {
  description = "GKE Autopilot cluster name"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "GKE Autopilot cluster control plane endpoint"
  value       = module.gke.endpoint
  sensitive   = true
}
