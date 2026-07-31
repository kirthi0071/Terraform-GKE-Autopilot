# -----------------------------------------------------------------------------
# VPC Network
# -----------------------------------------------------------------------------
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode            = var.routing_mode
}

# -----------------------------------------------------------------------------
# Subnetworks & Secondary Ranges
# -----------------------------------------------------------------------------
resource "google_compute_subnetwork" "subnets" {
  for_each = { for s in var.subnets : s.subnet_name => s }

  project                  = var.project_id
  name                     = each.value.subnet_name
  ip_cidr_range            = each.value.subnet_ip
  region                   = each.value.subnet_region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = tobool(lookup(each.value, "subnet_private_access", "true"))
  description              = lookup(each.value, "description", null)

  dynamic "secondary_ip_range" {
    for_each = lookup(var.secondary_ranges, each.key, [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = tobool(lookup(each.value, "subnet_flow_logs", "false")) ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

# -----------------------------------------------------------------------------
# Ingress Firewall Rules
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "ingress" {
  for_each = { for r in var.ingress_rules : r.name => r }

  project     = var.project_id
  name        = each.value.name
  description = lookup(each.value, "description", null)
  network     = google_compute_network.vpc.name
  priority    = lookup(each.value, "priority", 1000)

  source_ranges = lookup(each.value, "source_ranges", null)
  source_tags   = lookup(each.value, "source_tags", null)
  target_tags   = lookup(each.value, "target_tags", null)

  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }

  dynamic "deny" {
    for_each = lookup(each.value, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", null)
    }
  }
}

# -----------------------------------------------------------------------------
# Egress Firewall Rules
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "egress" {
  for_each = { for r in var.egress_rules : r.name => r }

  project     = var.project_id
  name        = each.value.name
  description = lookup(each.value, "description", null)
  network     = google_compute_network.vpc.name
  direction   = "EGRESS"
  priority    = lookup(each.value, "priority", 1000)

  destination_ranges = lookup(each.value, "destination_ranges", null)
  target_tags        = lookup(each.value, "target_tags", null)

  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }

  dynamic "deny" {
    for_each = lookup(each.value, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", null)
    }
  }
}
