# gke-platform

Root + child module Terraform layout that wires together four official
`terraform-google-modules` submodules into a working GKE Autopilot platform:

- `terraform-google-modules/network/google//modules/vpc`
- `terraform-google-modules/network/google//modules/subnets`
- `terraform-google-modules/network/google//modules/firewall-rules`
- `terraform-google-modules/iam/google//modules/service_accounts_iam`
- `terraform-google-modules/kubernetes-engine/google//modules/gke-autopilot-cluster`

## Folder structure

```
gke-platform/
├── README.md
├── modules/                     # reusable child modules (no state, no backend)
│   ├── network/                 # wraps vpc + subnets + firewall-rules
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/                     # creates GKE SA + wraps service_accounts_iam
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── gke/                     # wraps gke-autopilot-cluster
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    └── dev/                     # root module for the dev environment
        ├── backend.tf           # partial GCS backend config
        ├── backend-dev.hcl      # actual bucket/prefix for dev state
        ├── providers.tf
        ├── variables.tf
        ├── main.tf              # calls modules/network -> modules/iam -> modules/gke
        ├── outputs.tf
        └── dev.tfvars           # example variable values for dev
```

To add another environment (uat/prod), copy `environments/dev/` to
`environments/uat/`, edit `backend-dev.hcl` -> `backend-uat.hcl` (different
`prefix`, and a different bucket if you want stronger state isolation), and
`dev.tfvars` -> `uat.tfvars`.

## Remote state (GCS)

Backend blocks can't reference variables, so `backend.tf` is left as a
partial `gcs {}` block and the real values live in `backend-dev.hcl`,
supplied at init time. Create the state bucket once, before first init:

```bash
gsutil mb -p <project_id> -l asia-south1 gs://enhub-tfstate-dev
gsutil versioning set on gs://enhub-tfstate-dev
```

## Usage

```bash
cd environments/dev

terraform init -backend-config=backend-dev.hcl

terraform plan  -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

## Wiring notes

- `modules/network` creates the VPC, subnets (with secondary ranges for
  GKE pods/services), and firewall rules, then exposes
  `subnets_self_links` (a `subnet_name => self_link` map) and
  `network_self_link`.
- `environments/dev/main.tf` looks up the GKE subnet's self_link from that
  map using `var.gke_subnet_name`, and passes it + the pod/service
  secondary range names into `modules/gke`.
- `modules/iam` creates the node/workload service account and grants it
  the baseline project roles it needs (logging, monitoring, artifact
  registry read). Any extra bindings ON the SA itself (e.g. Workload
  Identity User for a specific Kubernetes SA) go through
  `service_accounts_iam` via `var.sa_bindings`.
- `modules/gke` wraps `gke-autopilot-cluster`, wiring in the network
  module's subnet/network self_links, the secondary range names, a
  `master_authorized_networks_config`, and
  `workload_identity_config.workload_pool = "<project_id>.svc.id.goog"`.
- `master_authorized_networks_config` and `workload_identity_config` are
  **required** inputs of `gke-autopilot-cluster` (no defaults) — make sure
  `dev.tfvars` sets a real CIDR you control for
  `master_authorized_networks`, not the example placeholder.

## Versions used

Pin these to whatever is current on the registry when you run this
(module majors bump periodically):

- `terraform-google-modules/network/google` ~> 9.0
- `terraform-google-modules/iam/google` ~> 8.0
- `terraform-google-modules/kubernetes-engine/google` ~> 36.0
- `hashicorp/google` provider ~> 6.0
