output "network_name" {
  description = "Name of the created VPC"
  value       = google_compute_network.vpc.name
}

output "network_self_link" {
  description = "Self link of the created VPC"
  value       = google_compute_network.vpc.self_link
}

output "network_id" {
  description = "ID of the created VPC"
  value       = google_compute_network.vpc.id
}

output "subnets" {
  description = "Map of created subnet resources"
  value       = google_compute_subnetwork.subnets
}

output "subnets_self_links" {
  description = "Map of subnet_name => self_link"
  value = {
    for name, s in google_compute_subnetwork.subnets :
    name => s.self_link
  }
}
