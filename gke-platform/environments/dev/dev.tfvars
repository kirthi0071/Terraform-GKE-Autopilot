# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
project_id = "enhub-dev-123456"
region     = "asia-south1"
env        = "dev"

# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------
network_name = "vpc-dev"

subnets = [
  {
    subnet_name           = "snet-gke-dev"
    subnet_ip              = "10.10.0.0/20"
    subnet_region          = "asia-south1"
    subnet_private_access  = "true"
    subnet_flow_logs       = "true"
    description             = "Primary subnet for GKE Autopilot nodes - dev"
  },
  {
    subnet_name           = "snet-mgmt-dev"
    subnet_ip              = "10.10.16.0/24"
    subnet_region          = "asia-south1"
    subnet_private_access  = "true"
    subnet_flow_logs       = "false"
    description             = "Management/bastion subnet - dev"
  }
]

secondary_ranges = {
  "snet-gke-dev" = [
    {
      range_name    = "gke-pods-dev"
      ip_cidr_range = "10.20.0.0/16"
    },
    {
      range_name    = "gke-services-dev"
      ip_cidr_range = "10.30.0.0/20"
    }
  ]
}

gke_subnet_name          = "snet-gke-dev"
gke_pods_range_name      = "gke-pods-dev"
gke_services_range_name  = "gke-services-dev"

ingress_rules = [
  {
    name          = "allow-iap-ssh-dev"
    description   = "Allow SSH from Identity-Aware Proxy range"
    priority      = 1000
    source_ranges = ["35.235.240.0/20"]
    allow = [
      {
        protocol = "tcp"
        ports    = ["22"]
      }
    ]
  },
  {
    name          = "allow-internal-dev"
    description   = "Allow all internal traffic within the VPC"
    priority      = 1000
    source_ranges = ["10.10.0.0/16"]
    allow = [
      { protocol = "tcp", ports = ["0-65535"] },
      { protocol = "udp", ports = ["0-65535"] },
      { protocol = "icmp" }
    ]
  }
]

egress_rules = [
  {
    name                = "allow-all-egress-dev"
    description         = "Allow all outbound traffic"
    priority            = 1000
    destination_ranges  = ["0.0.0.0/0"]
    allow = [
      { protocol = "all" }
    ]
  }
]

# -----------------------------------------------------------------------------
# IAM
# -----------------------------------------------------------------------------
gke_service_account_id = "gke-node-sa-dev"

sa_bindings = {
  # Example: let a specific Kubernetes ServiceAccount impersonate this GSA
  # via Workload Identity. Replace with your real KSA namespace/name.
  "roles/iam.workloadIdentityUser" = [
    "serviceAccount:enhub-dev-123456.svc.id.goog[default/app-ksa]"
  ]
}

# -----------------------------------------------------------------------------
# GKE
# -----------------------------------------------------------------------------
cluster_name = "gke-autopilot-dev"

master_authorized_networks = [
  {
    display_name = "corp-vpn"
    cidr_block   = "203.0.113.0/24"
  }
]

release_channel     = "REGULAR"
deletion_protection = false

resource_labels = {
  team  = "platform"
  owner = "enhub"
}
