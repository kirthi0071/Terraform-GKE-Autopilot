# Create this bucket once, manually or via a bootstrap Terraform config,
# BEFORE running `terraform init` here (a backend can't create its own bucket).
#
#   gsutil mb -p <project_id> -l asia-south1 gs://enhub-tfstate-dev
#   gsutil versioning set on gs://enhub-tfstate-dev

bucket = "enhub-tfstate-dev"
prefix = "gke-platform/dev"
