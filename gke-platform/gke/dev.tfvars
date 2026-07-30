project_id = "testing-project-499604"
region     = "asia-south1"

# Where to read the vpc/ and iam/ root modules' state from
vpc_state_bucket = "kirthi-tf"
vpc_state_prefix = "gke-platform/dev/vpc"

iam_state_bucket = "kirthi-tf"
iam_state_prefix = "gke-platform/dev/iam"

cluster_name = "gke-autopilot-dev"

gke_subnet_name          = "snet-gke-dev"
gke_pods_range_name      = "gke-pods-dev"
gke_services_range_name  = "gke-services-dev"

master_authorized_networks = [
  {
    display_name = "corp-vpn"
    cidr_block   = "203.0.113.0/24"   # <-- replace with your real allowed CIDR
  }
]

release_channel     = "REGULAR"
deletion_protection = false

resource_labels = {
  team  = "platform"
  owner = "enhub"
  env   = "dev"
}
