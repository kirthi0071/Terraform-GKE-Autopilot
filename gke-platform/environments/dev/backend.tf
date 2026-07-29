# Backend values are intentionally left blank here because a `backend` block
# cannot reference variables or .tfvars. Bucket/prefix are supplied at
# `terraform init` time via -backend-config, using backend-dev.hcl below.
#
#   terraform init -backend-config=backend-dev.hcl
#
terraform {
  backend "gcs" {}
}
