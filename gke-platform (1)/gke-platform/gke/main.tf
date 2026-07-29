# -----------------------------------------------------------------------------
# Pull outputs from the vpc/ and iam/ root modules' remote state, so this
# root module never has to duplicate their resources or hardcode self_links.
# -----------------------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config = {
    bucket = var.vpc_state_bucket
    prefix = var.vpc_state_prefix
  }
}

data "terraform_remote_state" "iam" {
  backend = "gcs"
  config = {
    bucket = var.iam_state_bucket
    prefix = var.iam_state_prefix
  }
}

locals {
  network_self_link    = data.terraform_remote_state.vpc.outputs.network_self_link
  gke_subnet_self_link = data.terraform_remote_state.vpc.outputs.subnets_self_links[var.gke_subnet_name]
  gke_sa_email          = data.terraform_remote_state.iam.outputs.service_account_email
}

module "gke" {
  source = "../modules/gke"

  project_id            = var.project_id
  cluster_name          = var.cluster_name
  region                = var.region
  network_self_link     = local.network_self_link
  subnetwork_self_link  = local.gke_subnet_self_link
  pods_range_name       = var.gke_pods_range_name
  services_range_name   = var.gke_services_range_name

  master_authorized_networks  = var.master_authorized_networks
  workload_pool               = "${var.project_id}.svc.id.goog"
  node_service_account_email  = local.gke_sa_email

  release_channel      = var.release_channel
  deletion_protection  = var.deletion_protection
  resource_labels      = var.resource_labels
}
