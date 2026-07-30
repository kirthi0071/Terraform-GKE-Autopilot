output "network_name" {
  description = "Name of the created VPC"
  value       = module.vpc.network_name
}

output "network_self_link" {
  description = "Self link of the created VPC"
  value       = module.vpc.network_self_link
}

output "network_id" {
  description = "ID of the created VPC"
  value       = module.vpc.network_id
}

output "subnets" {
  description = "Map of created subnet resources (keyed by region/name)"
  value       = module.subnets.subnets
}

# Convenience output: self_link of the primary GKE subnet, looked up by name.
# Assumes one of var.subnets is intended for the GKE cluster and is named
# accordingly (e.g. "gke-subnet") - adjust the key used in modules/gke as needed.
output "subnets_self_links" {
  description = "Map of subnet_name => self_link for easy lookup by callers"
  value = {
    for key, subnet in module.subnets.subnets :
    subnet.name => subnet.self_link
  }
}
