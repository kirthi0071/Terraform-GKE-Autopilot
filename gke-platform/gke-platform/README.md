# gke-platform

Three independent **root modules** — `vpc/`, `iam/`, `gke/` — each with its
own GCS backend/state, wired together via `terraform_remote_state`. Shared
logic lives in `modules/`, which has no state of its own; it's just
reusable wrappers around the official `terraform-google-modules`
submodules:

- `terraform-google-modules/network/google//modules/vpc`
- `terraform-google-modules/network/google//modules/subnets`
- `terraform-google-modules/network/google//modules/firewall-rules`
- `terraform-google-modules/iam/google//modules/service_accounts_iam`
- `terraform-google-modules/kubernetes-engine/google//modules/gke-autopilot-cluster`

## Folder structure

```
gke-platform/
├── README.md
├── modules/                      # shared child modules (no backend, no state)
│   ├── network/                  # wraps vpc + subnets + firewall-rules
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/                      # creates GKE SA + wraps service_accounts_iam
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── gke/                      # wraps gke-autopilot-cluster
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── vpc/                           # ROOT MODULE 1 — own state
│   ├── backend.tf
│   ├── backend-dev.hcl
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf                   # calls ../modules/network
│   ├── outputs.tf                # <- read by gke/ via remote state
│   └── dev.tfvars
│
├── iam/                           # ROOT MODULE 2 — own state, independent
│   ├── backend.tf
│   ├── backend-dev.hcl
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf                   # calls ../modules/iam
│   ├── outputs.tf                # <- read by gke/ via remote state
│   └── dev.tfvars
│
└── gke/                           # ROOT MODULE 3 — own state, depends on vpc + iam
    ├── backend.tf
    ├── backend-dev.hcl
    ├── providers.tf
    ├── variables.tf
    ├── main.tf                   # reads vpc/ and iam/ state, calls ../modules/gke
    ├── outputs.tf
    └── dev.tfvars
```

## Why three root modules instead of one

- **Independent lifecycles.** VPC and IAM rarely change once set up; GKE
  gets applied/upgraded far more often. Splitting state means a `gke`
  apply can never accidentally touch network or IAM resources.
- **Blast radius.** A bad `terraform apply` in `gke/` can't corrupt
  `vpc/`'s or `iam/`'s state — they're entirely separate `.tfstate` files.
- **Team boundaries.** Networking/platform teams can own `vpc/` and
  `iam/`; app platform teams can own `gke/`, applying it against whatever
  vpc/iam state is already there.

## Remote state (GCS)

Each root module gets its **own bucket prefix** (same bucket, different
`prefix`) so state files never collide:

```
gs://enhub-tfstate-dev/gke-platform/dev/vpc/default.tfstate
gs://enhub-tfstate-dev/gke-platform/dev/iam/default.tfstate
gs://enhub-tfstate-dev/gke-platform/dev/gke/default.tfstate
```

Create the bucket once, before the first `init` anywhere:

```bash
gsutil mb -p <project_id> -l asia-south1 gs://enhub-tfstate-dev
gsutil versioning set on gs://enhub-tfstate-dev
```

Backend blocks can't read variables, so each root's `backend.tf` is left
partial (`backend "gcs" {}`) and the real bucket/prefix live in that root's
`backend-dev.hcl`, supplied at init time.

## Apply order

```bash
# 1. VPC - no dependencies
cd vpc
terraform init  -backend-config=backend-dev.hcl
terraform apply -var-file=dev.tfvars

# 2. IAM - no dependencies, can run in parallel with vpc
cd ../iam
terraform init  -backend-config=backend-dev.hcl
terraform apply -var-file=dev.tfvars

# 3. GKE - reads vpc/ and iam/ state via terraform_remote_state
cd ../gke
terraform init  -backend-config=backend-dev.hcl
terraform apply -var-file=dev.tfvars
```

## How gke/ finds vpc/ and iam/ outputs

`gke/main.tf` declares two `data "terraform_remote_state"` blocks pointed
at the vpc and iam buckets/prefixes (set via `dev.tfvars` ->
`vpc_state_bucket`/`vpc_state_prefix`, `iam_state_bucket`/`iam_state_prefix`).
It then reads:

- `data.terraform_remote_state.vpc.outputs.network_self_link`
- `data.terraform_remote_state.vpc.outputs.subnets_self_links[var.gke_subnet_name]`
- `data.terraform_remote_state.iam.outputs.service_account_email`

...and feeds them into `modules/gke`, along with a required
`master_authorized_networks_config` (real CIDR — replace the placeholder
in `gke/dev.tfvars`) and `workload_identity_config.workload_pool`, which is
derived automatically as `"<project_id>.svc.id.goog"`.

## Adding another environment (uat/prod)

Per root module, add a `uat.tfvars` and a `backend-uat.hcl` (different
`prefix`, e.g. `gke-platform/uat/vpc`) — no folder duplication needed,
just extra var-file/backend-config pairs, e.g.:

```bash
cd vpc
terraform init  -backend-config=backend-uat.hcl
terraform apply -var-file=uat.tfvars
```

## CI/CD — GitHub Actions

`.github/workflows/terraform-pipeline.yml` runs on PRs and pushes to
`master`:

1. **`detect_changes`** — diffs the PR/push against its base and figures
   out which root modules (`vpc`, `iam`, `gke`) need to run. A change under
   `modules/` (shared code) forces all three, since all three roots call
   into it.
2. **`terraform-plan`** — matrix job, one run per changed component, in
   parallel (plan is read-only so ordering doesn't matter here). On PRs it
   comments the plan output back onto the PR via `mshick/add-pr-comment`.
3. **`terraform-apply-vpc`** / **`terraform-apply-iam`** — only on push to
   `master`, run in parallel, no dependency between them.
4. **`terraform-apply-gke`** — only on push to `master`, and only after
   `terraform-apply-vpc` and `terraform-apply-iam` have each either
   succeeded or been skipped (skipped = that component didn't change this
   run). This ordering matters because `gke/` reads `vpc/` and `iam/`
   outputs via `terraform_remote_state` — it must not apply against
   stale/uninitialized state.

### Required repo secrets

| Secret | Used for |
|---|---|
| `WIF_PROVIDER` | `projects/<PROJECT_NUMBER>/locations/global/workloadIdentityPools/<pool>/providers/<provider>` |
| `WIF_SERVICE_ACCOUNT` | `github-actions-sa@<project_id>.iam.gserviceaccount.com`, impersonated via Workload Identity Federation — no key files |

This pipeline assumes a single environment (`dev`, using each root's
`dev.tfvars` / `backend-dev.hcl`). To add `qa`/`prod`:

- Add `qa.tfvars`/`backend-qa.hcl` (and `prod.*`) next to each root's
  `dev.tfvars`/`backend-dev.hcl`.
- Add an env dimension to the `detect_changes` output (e.g.
  `vpc:qa`, `iam:prod`) and a per-env `WIF_PROVIDER_QA` /
  `WIF_PROVIDER_PROD` secret pair, following the same
  `contains(matrix..., 'qa')` conditional-auth pattern used for a single
  environment today.



Pin these to whatever is current on the registry when you run this
(module majors bump periodically):

- `terraform-google-modules/network/google` ~> 9.0
- `terraform-google-modules/iam/google` ~> 8.0
- `terraform-google-modules/kubernetes-engine/google` ~> 36.0
- `hashicorp/google` provider ~> 6.0
