# Create this bucket once before first init:
#   gsutil mb -p <project_id> -l asia-south1 gs://enhub-tfstate-dev
#   gsutil versioning set on gs://enhub-tfstate-dev
bucket = "enhub-tfstate-dev"
prefix = "gke-platform/dev/vpc"
