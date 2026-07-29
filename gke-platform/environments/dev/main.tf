locals {
  # Look up the self_link of the subnet the GKE cluster attaches to,
  # from the map of subnets created by the network module.
  gke_subnet_self_link = module.network.subnets_self_links[var.gke_subnet_name]
}

# -----------------------------------------------------------------------------
# 1. Network: VPC + Subnets + Firewall rules
# -----------------------------------------------------------------------------
module "network" {
  source = "../../modules/network"

  project_id       = var.project_id
  network_name     = var.network_name
  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
  ingress_rules    = var.ingress_rules
  egress_rules     = var.egress_rules
}

# -----------------------------------------------------------------------------
# 2. IAM: GKE service account + bindings
# -----------------------------------------------------------------------------
module "iam" {
  source = "../../modules/iam"

  project_id          = var.project_id
  service_account_id  = var.gke_service_account_id
  bindings            = var.sa_bindings
}

# -----------------------------------------------------------------------------
# 3. GKE: Autopilot cluster (depends on network + iam)
# -----------------------------------------------------------------------------
module "gke" {
  source = "../../modules/gke"

  project_id            = var.project_id
  cluster_name          = var.cluster_name
  region                = var.region
  network_self_link     = module.network.network_self_link
  subnetwork_self_link  = local.gke_subnet_self_link
  pods_range_name       = var.gke_pods_range_name
  services_range_name   = var.gke_services_range_name

  master_authorized_networks = var.master_authorized_networks
  workload_pool               = "${var.project_id}.svc.id.goog"

  release_channel      = var.release_channel
  deletion_protection  = var.deletion_protection
  resource_labels      = merge(var.resource_labels, { env = var.env })

  depends_on = [module.network, module.iam]
}
