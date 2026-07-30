module "network" {
  source = "../modules/network"

  project_id       = var.project_id
  network_name     = var.network_name
  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
  ingress_rules    = var.ingress_rules
  egress_rules     = var.egress_rules
}
# ci test Thu Jul 30 18:09:18 IST 2026
