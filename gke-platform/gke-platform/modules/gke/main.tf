module "gke_autopilot" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/gke-autopilot-cluster"
  version = "~> 44.3.0"

  project_id = var.project_id
  name       = var.cluster_name
  location   = var.region

  network    = var.network_self_link
  subnetwork = var.subnetwork_self_link

  ip_allocation_policy = {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  master_authorized_networks_config = {
    cidr_blocks = var.master_authorized_networks
  }

  cluster_autoscaling = {
    auto_provisioning_defaults = {
      service_account = var.node_service_account_email
    }
  }

  workload_identity_config = {
    workload_pool = var.workload_pool
  }

  release_channel = {
    channel = var.release_channel
  }

  deletion_protection = var.deletion_protection
  resource_labels     = var.resource_labels
}
