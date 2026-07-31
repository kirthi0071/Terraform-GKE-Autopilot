resource "google_container_cluster" "gke_autopilot" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  enable_autopilot = true

  network    = var.network_self_link
  subnetwork = var.subnetwork_self_link

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = var.node_service_account_email
    }
  }

  datapath_provider          = var.datapath_provider
  private_ipv6_google_access = var.private_ipv6_google_access

  workload_identity_config {
    workload_pool = var.workload_pool
  }

  release_channel {
    channel = var.release_channel
  }

  deletion_protection = var.deletion_protection
  resource_labels     = var.resource_labels
}
