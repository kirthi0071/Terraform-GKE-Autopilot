project_id = "testing-project-499604"
region     = "asia-south1"

service_account_id           = "gke-node-sa-dev"
service_account_display_name = "GKE Autopilot Node SA - dev"

project_roles = [
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter",
  "roles/monitoring.viewer",
  "roles/stackdriver.resourceMetadata.writer",
  "roles/artifactregistry.reader",
]

# Keep this empty until GKE cluster exists
sa_bindings = {
# "roles/iam.workloadIdentityUser" = [
 #   "serviceAccount:testing-project-499604.svc.id.goog[default/app-ksa]"
  ]
}
