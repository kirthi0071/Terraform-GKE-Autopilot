# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "~> 9.0"

  project_id              = var.project_id
  network_name            = var.network_name
  routing_mode            = var.routing_mode
  auto_create_subnetworks = var.auto_create_subnetworks
}

# -----------------------------------------------------------------------------
# Subnets (+ secondary ranges for GKE pods/services)
# -----------------------------------------------------------------------------
module "subnets" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "~> 9.0"

  project_id   = var.project_id
  network_name = module.vpc.network_name

  subnets = [
    for s in var.subnets : {
      subnet_name           = s.subnet_name
      subnet_ip             = s.subnet_ip
      subnet_region         = s.subnet_region
      subnet_private_access = s.subnet_private_access
      subnet_flow_logs      = s.subnet_flow_logs
      description           = s.description
    }
  ]

  secondary_ranges = var.secondary_ranges

  depends_on = [module.vpc]
}

# -----------------------------------------------------------------------------
# Firewall rules
# -----------------------------------------------------------------------------
module "firewall_rules" {
  source  = "terraform-google-modules/network/google//modules/firewall-rules"
  version = "~> 9.0"

  project_id   = var.project_id
  network_name = module.vpc.network_name

  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules

  depends_on = [module.vpc]
}
