# Getting started: cloud pairs and the local AI/GPU track

Choose your stage in the [learning path](LEARNING_PATH.md) first. Sections 1–12 are the operating
sequence for the cloud core: this hub and six paired repositories. Start with AWS, then compare
Azure and Google Cloud. The [cloud lesson catalog](CURRICULUM.md) and
[acceptance matrix](ACCEPTANCE.md) map exercises, evidence and limits. Section 13 introduces the
independent [local AI/GPU track](AI_GPU_TRACK.md), the eighth repository in the learning map.

**Cloud-core status:** DEC-13 construction is delivered and exercised with mocks, Docker/kind and GitHub Actions.
Cloud paths remain **`not run in the cloud (v2)`**. Your first account run is a validation
exercise and may reveal fixes. A trial account does not make the complete lab free.

## Contents

1. [Choose a path and profiles](#1-choose-a-path-and-profiles)
2. [Fork and configure GitHub](#2-fork-and-configure-github)
3. [Complete CI and local learning](#3-complete-ci-and-local-learning)
4. [Create dedicated cloud accounts](#4-create-dedicated-cloud-accounts)
5. [Bootstrap state and federated identities](#5-bootstrap-state-and-federated-identities)
6. [Set variables and secrets](#6-set-variables-and-secrets)
7. [Prepare cost, DNS and capacity](#7-prepare-cost-dns-and-capacity)
8. [Run infrastructure and platform workflows](#8-run-infrastructure-and-platform-workflows)
9. [Publish and deploy the approved app](#9-publish-and-deploy-the-approved-app)
10. [Validate the complete scope](#10-validate-the-complete-scope)
11. [Destroy and check leftovers](#11-destroy-and-check-leftovers)
12. [Troubleshooting and next sessions](#12-troubleshooting-and-next-sessions)
13. [Continue to local AI and GPU infrastructure](#13-continue-to-local-ai-and-gpu-infrastructure)

## 1. Choose a path and profiles

| Cloud | Infrastructure (TX) | Application (DX) | Kubernetes / database |
|---|---|---|---|
| AWS | [tx01v2](https://github.com/maringelix/tx01v2) | [dx01v2](https://github.com/maringelix/dx01v2) | EKS / RDS PostgreSQL |
| Azure | [tx02v2](https://github.com/maringelix/tx02v2) | [dx02v2](https://github.com/maringelix/dx02v2) | AKS / PostgreSQL Flexible Server |
| Google Cloud | [tx03v2](https://github.com/maringelix/tx03v2) | [dx03v2](https://github.com/maringelix/dx03v2) | GKE Autopilot / Cloud SQL PostgreSQL |
| All | [tx00v2](https://github.com/maringelix/tx00v2) | central guide, curriculum and family checks | no cloud infrastructure or credentials |

All DX repositories run the same React/Express/TypeScript app. Learn one pair first, then compare
the other providers' networking, identity and managed services.

| Choice | Meaning | Resources/cost |
|---|---|---|
| Local core | smaller introductory platform | no cloud account; see TX LOCAL_LAB |
| Local full, default | portable complete platform/app exercises | 8 GB Docker for the basic profile |
| Local full, small | same learning components with reduced resources | one node, 7 GB Docker; separate CI job |
| Local HA + FinOps | capacity/drain/HPA/showback/rightsizing | three kind nodes, 12 GiB recommended; do not combine with small |
| Cloud platform core | economical entry, direct app deployment | paid Kubernetes/database/network; no Argo CD/full observability stack |
| Cloud platform full | GitOps, mesh, policies, observability, backup and Chaos integrations | more capacity and provider DNS/TLS prerequisites |
| Cloud data core / ha / dr | database resilience chosen separately from platform | ha adds managed HA/retention; dr adds a second paid regional runtime |
| Cloud FinOps installation | optional OpenCost/VPA on full | reviewed rates; plan/apply cost gate is mandatory even without this stack |

LOCAL_PROFILE, LOCAL_SIZE and LOCAL_TOPOLOGY control local exercises. Cloud platform.profile,
DX platform_profile and database profile variables are separate inputs. Installing core does
not install all technologies demonstrated by full.

## 2. Fork and configure GitHub

1. On GitHub, fork both repositories of your chosen pair into the same user/organization.
   Keep exact names such as tx01v2 and dx01v2. Fork other pairs when ready.
2. Open **Actions** in each fork and enable workflows. Settings, environments, variables, secrets
   and rulesets are not copied from upstream.
3. Clone your forks. Examples use Bash on Linux/WSL or the repository devcontainer:

```bash
OWNER=your-github-owner
TX=tx01v2                         # tx02v2 or tx03v2
DX=dx01v2                         # matching dx02v2 or dx03v2
gh auth login
gh repo clone "$OWNER/$TX"
gh repo clone "$OWNER/$DX"
(cd "$TX" && bash scripts/repo-guardrails.sh "$OWNER/$TX")
(cd "$DX" && bash scripts/repo-guardrails.sh "$OWNER/$DX")
gh variable set "${TX^^}_REPO" --repo "$OWNER/$DX" --body "https://github.com/$OWNER/$TX.git"
```

Guardrails needs permission to administer your repositories. It sets required CI, secret
protection and a protected lab environment restricted to main with a reviewer. Read back its
result/settings. Resolve unsupported visibility/GitHub-plan protection before cloud deployment;
do not remove checks to proceed.

4. Check deploy/local/tx0Nv2.ref in DX: the commit must exist on your TX fork's main. A fresh fork
   contains upstream history. After local-platform changes, merge TX first, pin its merged SHA
   in DX and pass DX CI again.
5. Obtain immutable numeric IDs privately for bootstrap:

```bash
gh api "users/$OWNER" --jq .id
gh api "repos/$OWNER/$TX" --jq .id
gh api "repos/$OWNER/$DX" --jq .id
```

Use IDs as well as names. Guardrails checks OIDC subjects; older repositories may require the
immutable-claims opt-in in FORK.md. Never upload AWS access keys, Azure client secrets or Google
service-account key files.

Optionally fork TX00. Its family job expects all six repositories under the selected owner.
All six forks work with the default owner. With a partial fork, FAMILY_OWNER=maringelix checks
upstream, **not your partial family**. The hub needs no cloud secrets.
The optional tx04v2 track does not add a seventh cloud checkout or a new TX/DX contract.
Upstream documentation links intentionally remain under maringelix; dispatch workflows in your forks.

## 3. Complete CI and local learning

Wait for complete credential-free CI in both forks. TX runs static/test/e2e; DX runs
static/test/images/e2e/e2e-platform/continuity/e2e-platform-small on clean runners with disposable
services and pinned dependencies. No maintainer cloud credentials are needed. SonarQube uses a
disposable server/token; no paid Sonar account or persistent Sonar secret is required.

Follow A01–A16 in the [curriculum](CURRICULUM.md). Each LOCAL_LAB covers installation, memory,
probes, diagnostics and teardown. Heavy full/HA/Sonar/DR/load runs can stay in Actions when your
local machine does not have enough resources.

On a sufficiently provisioned Linux/WSL host:

```bash
(cd "$TX" && make tools && HARNESS_STRICT=1 make verify)
(cd "$TX" && make e2e)            # disposable full platform, including cleanup
(cd "$DX" && make tools && make e2e-platform)
```

Run one heavy exercise at a time. Use DX's pinned .nvmrc Node version. Destructive integration
tests require an isolated *_test database; never point them at your application database.
Keep build/tool/provider caches outside OneDrive source folders using documented container volumes.

**Checkpoint:** green CI in both forks, DX pin present in your TX history, expected probes/results
understood. No cloud account is needed yet.

## 4. Create dedicated cloud accounts

Create only the next account you intend to use: trial clocks may start at signup. Check current
eligibility, service availability, region/SKU quotas, payment terms and credits in your console.
Managed Kubernetes, databases, NAT, LB/WAF, disks and secondary regions can incur charges.
Full/HA/DR is not a free-tier promise.

### AWS

1. Use official [AWS signup](https://signup.aws.amazon.com/) and review
   [Free/Paid plan terms](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-plans.html).
   Free has service/feature restrictions and a limited lifetime; verify all dependencies.
   Moving to Paid changes billing exposure.
2. Use a dedicated lab account; secure root with MFA and create a human administrative login/role
   for bootstrap. Keep root credentials out of daily CLI work and GitHub.
3. Select a region supporting pinned EKS/RDS versions and instance types. Defaults: primary
   us-east-1, DR us-west-2. Check EKS/EC2/vCPU/RDS quotas.
4. Read [AWS costs](https://github.com/maringelix/tx01v2/blob/main/docs/COSTS.md). Prepare budget
   recipients and an owned public Route53 zone for DNS/TLS.

### Azure

1. Use official [Azure account options](https://azure.microsoft.com/en-us/pricing/purchase-options/azure-account),
   complete identity/payment checks and review credit duration, subscription restrictions and
   pay-as-you-go upgrade terms.
2. Use a dedicated lab subscription in the intended Entra tenant. The human bootstrap identity
   needs subscription Owner; data-plane access follows the runbook.
3. Check AKS/VM-family/PostgreSQL quotas (default eastus2). Trial subscriptions may need quota
   changes or may lack your selected SKU.
4. Read [Azure costs](https://github.com/maringelix/tx02v2/blob/main/docs/COSTS.md); prepare budget
   recipients and, for full, a public domain/DNS zone and ACME contact.

### Google Cloud

1. Read the official [trial guide](https://docs.cloud.google.com/free/docs/free-cloud-features):
   eligibility, restricted products, quotas and paid-upgrade consequences.
2. Create a [dedicated project](https://docs.cloud.google.com/resource-manager/docs/creating-managing-projects)
   and link billing. Project ID, project number and billing account ID differ; retain them privately.
3. Bootstrap needs project Owner plus permission to create budgets on the billing account.
   Project Owner alone does not grant that billing permission.
4. Check GKE/Cloud SQL/CPU/IP quotas (defaults us-central1 primary, us-east1 DR).
   Read [Google costs](https://github.com/maringelix/tx03v2/blob/main/docs/COSTS.md).
   Full needs a delegated public domain and managed mesh.

**Checkpoint:** dedicated scope, regions, quotas, payment exposure and same-day cleanup window
understood. Budgets notify; they do not shut resources down.

## 5. Bootstrap state and federated identities

Bootstrap runs once with your **human administrative identity on your machine**. It creates
state storage, CI identities/trust and budgets, before configuring GitHub cloud variables.
It does not deploy the whole lab.

| Provider | Human authentication/preflight | Required bootstrap inputs |
|---|---|---|
| AWS | AWS CLI v2 admin session with MFA; confirm account/region | github_owner, github_owner_id, tx01v2_repository_id, dx01v2_repository_id, budget_alert_emails |
| Azure | az login; az account set to intended subscription | subscription_id, github_owner, github_owner_id, tx02v2_repository_id, dx02v2_repository_id, budget_alert_emails |
| GCP | dedicated CLOUDSDK_CONFIG; gcloud auth login and deliberate application-default login; scripts/preflight.sh --project YOUR_PROJECT_ID | project_id, billing_account, github_owner, github_owner_id, tx03v2_repository_id, dx03v2_repository_id, budget_alert_emails |

From your TX clone, read the provider bootstrap/runbook, then:

```bash
cd "$TX"
export PATH="$PWD/.tools/bin:$PATH"
cp terraform/bootstrap/terraform.tfvars.example terraform/bootstrap/terraform.tfvars
# Edit ignored tfvars with your values; review account, region and costs.
terraform -chdir=terraform/bootstrap init -lockfile=readonly
terraform -chdir=terraform/bootstrap plan -out=tfplan
terraform -chdir=terraform/bootstrap apply tfplan
```

Use pinned Terraform from make tools with HARNESS's PATH setup. Apply is billable and must be
your deliberate action. Keep tfvars, binary plans, bootstrap state/backups, backend configuration
and credentials private. Securely retain bootstrap state between sessions.

Before first bootstrap:

- AWS: aws_region/dr_region must match later settings. If GitHub OIDC already exists, set
  create_github_oidc_provider=false to read it without owning its lifecycle. Use the owned
  lab_route53_zone_id for DNS. enable_state_dr is an explicit recovery choice.
- Azure: match location; state_replication_type defaults LRS, RAGRS is the documented state-DR
  option. state_protection_lock defaults true.
- GCP: match region. For two-US-region DR choose state_location=US before creating the bucket;
  do not replace existing state storage to change location. application-default login may
  replace host ADC; isolate and retain lab SDK configuration.

**Checkpoint:** successful bootstrap, protected state, initial github_variables_TX/DX output maps
using the actual repository names.

## 6. Set variables and secrets

Use **Settings → Secrets and variables → Actions** or gh in each fork.
Use repository variables for terraform-plan inputs: plan does not use the lab environment.
Use secrets for webhooks/passwords/operator lists. Secrets consumed only by protected jobs can
live in lab; repository secrets also work. Do not publish output maps in issues/logs.

Use repository secrets for the operator table below by default. Plan reads AWS endpoint/domain
secrets, Azure API-range/admin/deployer lists and GCP deployer members without an environment;
those must be repository secrets. Optional Slack/backup keys used only by protected jobs may
instead live in lab. Setting a plan input only in lab makes it unavailable to terraform-plan.

Import initial bootstrap maps from inside your TX clone:

```bash
terraform -chdir=terraform/bootstrap output -json "github_variables_$TX" |
  jq -r 'to_entries[] | "\(.key)=\(.value)"' |
  gh variable set --repo "$OWNER/$TX" --env-file -
terraform -chdir=terraform/bootstrap output -json "github_variables_$DX" |
  jq -r 'to_entries[] | "\(.key)=\(.value)"' |
  gh variable set --repo "$OWNER/$DX" --env-file -
```

These are configuration identifiers, not authentication keys. Add operator-selected settings after
importing. Both forks require their own map.

| Repository | Bootstrap repository variables |
|---|---|
| tx01v2 | AWS_REGION, TF_STATE_BUCKET, AWS_PLAN_ROLE_ARN, AWS_APPLY_ROLE_ARN, LAB_CLUSTER_ADMIN_PRINCIPAL_ARNS, LAB_APP_DEPLOYER_PRINCIPAL_ARNS |
| dx01v2 | AWS_REGION, AWS_DEPLOY_ROLE_ARN |
| tx02v2 | AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID, AZURE_PLAN_CLIENT_ID, AZURE_APPLY_CLIENT_ID, TF_STATE_STORAGE_ACCOUNT, LAB_LOCATION, LAB_DEPLOY_PRINCIPAL_ID |
| dx02v2 | AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID, AZURE_APPCONFIG_ENDPOINT |
| tx03v2 | GCP_PROJECT_ID, GCP_REGION, GCP_WORKLOAD_IDENTITY_PROVIDER, GCP_PLAN_SERVICE_ACCOUNT, GCP_APPLY_SERVICE_ACCOUNT, TF_STATE_BUCKET, LAB_DEPLOY_SERVICE_ACCOUNT |
| dx03v2 | GCP_PROJECT_ID, GCP_WORKLOAD_IDENTITY_PROVIDER, GCP_DEPLOY_SERVICE_ACCOUNT |

AWS: keep apply in LAB_CLUSTER_ADMIN_PRINCIPAL_ARNS and optionally add your human IAM role
(role ARN, not STS session ARN). Keep deploy in LAB_APP_DEPLOYER_PRINCIPAL_ARNS.

Azure: import github_secrets_tx02v2, then add your human object ID to the JSON array while retaining
the apply principal:

```bash
terraform -chdir=terraform/bootstrap output -json github_secrets_tx02v2 |
  jq -r 'to_entries[] | "\(.key)=\(.value)"' |
  gh secret set --repo "$OWNER/tx02v2" --env-file -
```

### Operator secrets and access

| TX | Name | Type/requirement |
|---|---|---|
| AWS | LAB_ENDPOINT_PUBLIC_ACCESS_CIDRS | required Secret; JSON EKS API source CIDRs |
| AWS | LAB_ALLOW_ENDPOINT_FROM_ANYWHERE | Variable; explicit true with 0.0.0.0/0 |
| AWS | LAB_APP_DOMAIN_NAME + LAB_ROUTE53_PUBLIC_ZONE_ID | paired Secrets for owned DNS/ACM HTTPS; zone matches bootstrap |
| AWS | LAB_VELERO_REPOSITORY_PASSWORD | Secret required for first full install; same escrowed 64-hex key in both regions |
| AWS | SLACK_WEBHOOK_URL | optional Secret for external full alerts |
| Azure | LAB_CLUSTER_ADMIN_PRINCIPAL_IDS | required Secret; JSON apply/human admin object IDs |
| Azure | LAB_API_SERVER_AUTHORIZED_IP_RANGES | required Secret; JSON AKS API source CIDRs |
| Azure | LAB_ALLOW_API_SERVER_FROM_ANYWHERE | Variable; explicit true with 0.0.0.0/0 |
| Azure | LAB_APP_DEPLOYER_PRINCIPAL_IDS | optional Secret JSON extra laptop deployers, default [] |
| Azure | LAB_VELERO_REPOSITORY_PASSWORD | full/DR Secret; stable 64-hex key escrowed outside both regions |
| Azure | LAB_SLACK_WEBHOOK_URL | optional Secret; note Azure's LAB_ prefix |
| GCP | LAB_APP_DEPLOYER_MEMBERS | optional Secret JSON user:/serviceAccount: list, default []; no groups |
| GCP | SLACK_WEBHOOK_URL | optional Secret for full Slack |

Hosted runners have changing egress IPs. The documented AWS/Azure learning path explicitly opens
the Kubernetes API source range with its allow variable; IAM/federation/RBAC still apply.
Restricted CIDRs require a reachable runner with matching egress. Documentation addresses such
as 203.0.113.10/32 are not your real address.

Use gh secret set NAME --repo OWNER/REPO interactively or protected stdin; keep secrets out of
command history. Escrow backup encryption keys before backups. Reinstallations preserve the
existing key instead of silently rotating it.

### Optional feature variables

| Provider | Choose before plan/apply |
|---|---|
| AWS | LAB_NODE_INSTANCE_TYPES/LAB_NODE_DESIRED_SIZE; LAB_ENABLE_SPOT_POOL; LAB_DB_PROFILE=core\|ha\|dr; LAB_DR_REGION/LAB_DR_VPC_CIDR; retention/deletion/final-snapshot settings |
| Azure | LAB_NODE_VM_SIZE (full recommendation Standard_D2as_v5), LAB_NODE_COUNT (full: 2); LAB_DNS_ZONE_NAME/LAB_APP_DOMAIN_NAME/LAB_ACME_CONTACT_EMAIL; LAB_POSTGRES_PROFILE=core\|ha\|dr; LAB_DR_LOCATION/DR CIDRs; LAB_ACTIVE_REGION; HA/retention/locks; LAB_ENABLE_SPOT_POOL/LAB_SPOT_MAX_PRICE |
| GCP | LAB_DNS_ZONE_NAME/LAB_APP_DOMAIN_NAME/LAB_ENABLE_MANAGED_MESH=true for full; LAB_DB_PROFILE=core\|ha\|dr; LAB_HA_DB_TIER; LAB_DR_REGION/DR CIDRs; LAB_ACTIVE_REGION; backup/deletion/retention |

For secondary deploy, AWS DX also needs selected LAB_DR_REGION; Azure DX needs
AZURE_DR_APPCONFIG_ENDPOINT from lab output dr_appconfig_endpoint. GCP DX uses target=secondary
to select the recovery contract, cluster and GitOps branch; its region comes from that contract.
A target/DNS setting is not database promotion.

Complete optional definitions and constraints:

| Provider | TX setup | DX setup | Recovery/cost inputs |
|---|---|---|---|
| AWS | [RUNBOOK](https://github.com/maringelix/tx01v2/blob/main/docs/RUNBOOK.md) | [RUNBOOK](https://github.com/maringelix/dx01v2/blob/main/docs/RUNBOOK.md) | [CONTINUITY](https://github.com/maringelix/tx01v2/blob/main/docs/CONTINUITY.md), [FINOPS](https://github.com/maringelix/tx01v2/blob/main/docs/FINOPS.md) |
| Azure | [RUNBOOK](https://github.com/maringelix/tx02v2/blob/main/docs/RUNBOOK.md) | [RUNBOOK](https://github.com/maringelix/dx02v2/blob/main/docs/RUNBOOK.md) | [CONTINUITY](https://github.com/maringelix/tx02v2/blob/main/docs/CONTINUITY.md), [FINOPS](https://github.com/maringelix/tx02v2/blob/main/docs/FINOPS.md) |
| GCP | [RUNBOOK](https://github.com/maringelix/tx03v2/blob/main/docs/RUNBOOK.md) | [RUNBOOK](https://github.com/maringelix/dx03v2/blob/main/docs/RUNBOOK.md) | [CONTINUITY](https://github.com/maringelix/tx03v2/blob/main/docs/CONTINUITY.md), [FINOPS](https://github.com/maringelix/tx03v2/blob/main/docs/FINOPS.md) |

## 7. Prepare cost, DNS and capacity

### Mandatory cost inputs in every TX

| Repository variable | Required value |
|---|---|
| LAB_FINOPS_PRICING_JSON | complete reviewed provider/region USD worksheet; HTTPS source, asOf within 31 days, mode=estimate |
| LAB_COST_BUDGET_USD | positive bound for the estimated run |
| LAB_COST_HOURS | priced duration, at most 24 hours |
| LAB_COST_EXPIRES_AT | future UTC deadline within 24 hours, covered by that duration |

First prepare an authenticated **read-only local lab plan**, using the backend and tfvars from
your TX RUNBOOK. Keep its binary/JSON private. The worksheet helper consumes that saved plan:

```bash
umask 077
terraform -chdir=terraform/envs/lab show -json tfplan > /tmp/plan-private.json
# CLOUD is aws, azure or gcp; REGION is your selected primary region.
CLOUD=aws                        # azure or gcp for the other pairs
REGION=us-east-1                  # match your actual bootstrap/lab region
bash scripts/cost-pricing-template.sh "$CLOUD" "$REGION" /tmp/plan-private.json /tmp/rates.json
```

Fill the deliberately incomplete worksheet using current prices for the largest planned
node/database configuration, including HA/DR. Include all Terraform resource types and
externalHourly categories backup/controlPlane/database/dr/egress/loadBalancer/nat/storage/waf.
Zero needs a real free/already-counted justification. Fill positive OpenCost CPU/RAM/storage
decimal-string rates too. Never use platform/finops/pricing/local.json as a cloud quote.

Upload the reviewed JSON to LAB_FINOPS_PRICING_JSON and set the other three variables.
Refresh deadlines every session and prices when region/scope changes. Correct a failed cost
gate rather than inventing zero rates. Secondary FinOps installation needs secondary-region
rates. Budget/estimate gates are not billing caps or automatic destruction.

### Full-profile prerequisites

- AWS: choose node capacity from COSTS, configure owned DNS/domain for HTTPS, and escrow the
  Velero key before full installation.
- Azure: set full-sized nodes, DNS zone/domain and ACME contact before plan/apply. After apply,
  delegate dns_name_servers at the registrar and wait for public DNS/CNAME resolution before
  the full installer requests certificates.
- GCP: enable managed mesh and DNS/domain before plan/apply. Delegate Cloud DNS and wait for
  managed certificate/Cloud Service Mesh readiness. Full uses supported managed mesh/sidecars.

Terraform completion does not prove DNS/certificate readiness. Follow provider RUNBOOK checks;
propagation and managed provisioning can take time.

## 8. Run infrastructure and platform workflows

Dispatch your fork's main. Review the plan, cost report, target and scope before approving
mutations. terraform-apply creates a fresh saved plan and repeats the cost gate; it does not
blindly apply an old terraform-plan artifact.

| Order | Repository/workflow | Inputs | Expected checkpoint |
|---|---|---|---|
| 1 | TX terraform-plan.yml | no manual inputs | reviewed plan/cost gate; restricted read identity, no lab approval |
| 2 | TX terraform-apply.yml | no inputs | lab approval and gated saved-plan apply |
| 3 | TX platform.yml | action=install; profile=core or full; target=primary; finops=false initially | lab approval, healthy installed components/contract |
| 4 | DX publication/deploy | section 9 | approved artifacts promoted and smoke passes |

Example dispatches after configuration:

```bash
gh workflow run terraform-plan.yml --repo "$OWNER/$TX" --ref main
# Inspect that run's plan/cost result and wait for success.
gh workflow run terraform-apply.yml --repo "$OWNER/$TX" --ref main
# Approve lab, wait for success, complete provider DNS prerequisites for full.
gh workflow run platform.yml --repo "$OWNER/$TX" --ref main -f action=install -f profile=core -f target=primary -f finops=false
```

When using full, change both platform and app profiles. finops=true requires full and reviewed
rates. AWS alone also has activate_dns; keep it false on secondary until fenced recovery
cutover is explicitly accepted.

Use Actions logs or gh run watch RUN_ID --exit-status --repo OWNER/REPO. Record actual run IDs
privately. Pending lab approval is not a failure. Do not proceed while prerequisites fail or wait.

## 9. Publish and deploy the approved app

The complete supported path is **successful main CI → publish-images → deploy**.
A successful PR run is insufficient. The source SHA must match current main.
Publication verifies six source checks: static, test, images, e2e, e2e-platform, continuity.
The complete app CI also runs e2e-platform-small.

1. List successful push CI runs in DX and check the exact source SHA:

```bash
gh run list --repo "$OWNER/$DX" --workflow ci.yml --branch main --event push --status success --json databaseId,headSha,conclusion
```

2. Set CI_RUN_ID to that databaseId and publish:

```bash
gh workflow run publish-images.yml --repo "$OWNER/$DX" --ref main -f ci_run_id="$CI_RUN_ID"
```

The workflow verifies the tested archive, publishes the tested images to GHCR, scans digests,
writes SBOM/provenance and signs the release without rebuilding. It needs no custom registry
password or static cloud key.

3. Wait for successful publication. Set RELEASE_RUN_ID to **that publish-images run ID**, not
   the original CI ID. Choose the matching deploy filename:

| DX | Workflow |
|---|---|
| dx01v2 | deploy-aws.yml |
| dx02v2 | deploy-azure.yml |
| dx03v2 | deploy-gcp.yml |

```bash
DEPLOY_WORKFLOW=deploy-aws.yml     # match your cloud
gh workflow run "$DEPLOY_WORKFLOW" --repo "$OWNER/$DX" --ref main -f release_run_id="$RELEASE_RUN_ID" -f platform_profile=core -f deploy_mode=auto -f target=primary
```

Match platform_profile to the installed TX profile. auto uses the Argo CD path when its
Application exists and direct deployment otherwise; explicit gitops requires Argo CD.
Before lab approval the job verifies the release. After approval it authenticates through
federation, promotes approved images to ECR/ACR/Artifact Registry without rebuilding,
attests/verifies promotion, deploys and runs smoke.

Full admission expects workflow-identity promotion attestations. A laptop deploy-script call
does not issue them and is not an equivalent full path. Do not bypass admission for unsigned
manual deployment.

**Checkpoint:** selected SHA/digests deployed, migration/readiness passed, full GitOps
Synced/Healthy, smoke passed at the intended endpoint.

## 10. Validate the complete scope

Use [ACCEPTANCE.md](ACCEPTANCE.md) and A01–A17 in the curriculum as your evidence checklist.
Run a bounded session per cloud. Record revision, profiles, regions, cost, commands/run IDs,
expected/observed results, failures, recovery and cleanup.

| Layer | Verify in your real account |
|---|---|
| Kubernetes/identity | managed cluster readiness, least-privilege access, federation and wrong-identity denial |
| Network/TLS/WAF | private database, ingress, DNS, public issuance/renewal/redirect and native WAF denial |
| App/CI/CD | content/digests, signed promotion, migrations, readiness, rollout/rollback and measured requests |
| GitOps/policies | sync/self-heal, unsafe-pod/artifact rejection, private-image scan reports |
| Observability | targets/dashboard, correlated log/trace/exemplar, native ingestion and actual Slack delivery |
| Backup/HA | native backups/PITR, isolated restore with known data, applicable PVC checksum and app reconnect |
| DR | independent second region, backup age/lag, fencing, data promotion, pre-DNS TLS smoke, RPO/RTO/failback |
| Capacity/Chaos | bounded hypotheses, HPA/node scaling, supported Spot interruption/fallback and recovery |
| FinOps | positive allocation/showback, VPA recommendations, current rates, retained/external costs and billed-cost comparison |

Start core, then full, then separately approved HA/DR/capacity exercises. A core primary run does
not validate full or a secondary region. Autopilot uses supported managed-mesh/Chaos alternatives
and has a different experiment surface from kind/EKS/AKS.

For DR follow both pair CONTINUITY runbooks: fence the writer, accept lag/loss, promote data,
synchronize secrets/certificates, verify the regional destination before DNS, then permit writes.
LAB_ACTIVE_REGION and target=secondary select routing/deployment; neither promotes a database.
Preserve backup keys and state recovery outside the failed region.

Submit cloud_run_report in the lab repository with sanitized evidence. Keep real IDs, addresses,
tokens, webhook URLs and raw Terraform plans/state out of public material. Local probes do not
establish managed failover, billed savings or 24/7 operation.

## 11. Destroy and check leftovers

Cleanup is part of every session, including failures. Stop load/Chaos first. Review deletion
protection, retained backups/recovery buckets and keys. Disable deletion locks only through
their documented reviewed procedure.

| TX | terraform-destroy.yml confirm input |
|---|---|
| tx01v2 | destroy tx01v2-lab |
| tx02v2 | destroy tx02v2-lab |
| tx03v2 | destroy tx03v2-lab |

```bash
gh workflow run terraform-destroy.yml --repo "$OWNER/$TX" --ref main -f confirm="destroy $TX-lab"
```

Approve lab and inspect the complete result. force_unlock_id is for the exact reviewed lock
of an interrupted run, after confirming no apply is active; never unlock to speed up a pipeline.

Scripts stop reconciliation/uninstall platform, remove owned controller LB components, destroy
Terraform and check leftovers. Complete the provider inventory as a human administrator in
**both regions**: disks, IPs, snapshots, registry images, backup-object versions, soft-deleted
resources, state copies and keys.

- AWS: archive/preserve or deliberately delete retained snapshots/backups/recovery storage.
  KMS keys have a separate lifecycle. Preserve an existing account-wide GitHub OIDC provider.
- Azure: use the exact documented Key Vault purge; account for disks, Blob versions, recovery
  storage and escrow keys.
- GCP: when deliberately discarding backups, Owner empties both owned Velero buckets as documented
  (force_destroy=false). Run scripts/leftovers.sh --project YOUR_PROJECT_ID as Owner to complete
  the inventory beyond the limited CI identity.

Successful Terraform destruction does not prove a zero bill. Record retained resources/costs
and inspect billing after usage propagates.

Bootstrap is retained between sessions. Its storage, identities/APIs, budget and locks need
a separate final human teardown after preserving required state/backups. Destroy the dependent
lab before bootstrap. The hub has no cloud infrastructure to destroy.

## 12. Troubleshooting and next sessions

| Symptom | Check/recovery |
|---|---|
| Actions disabled/protection refused | enable workflows; verify repository/admin access and supported environment protection; rerun guardrails |
| OIDC/WIF rejected | immutable numeric owner/repo IDs, subject opt-in, main ref, lab context and selected cloud scope |
| Kubernetes API unreachable | runner egress versus CIDRs, explicit allow flag, roles/access entries; never use an unrelated host kubeconfig |
| Cost gate fails | unpriced types/categories, wrong region, stale date, expired deadline or scope over budget |
| Full install refuses | capacity, delegated DNS, certificate/mesh readiness and escrowed backup key |
| Publisher rejects CI run | push main, exact current SHA, successful source checks and retained artifacts |
| Admission rejects images | publisher run ID, checksum/identity, promotion attestation and registry digest; republish through approved flow |
| No Slack delivery | exact provider-specific secret and actual webhook; local sink is not external delivery |
| Restore/DR fails | region, current keys/certificates/secrets, backup age/lag and fencing; follow CONTINUITY |
| Destroy/leftovers fail | interrupted-run recovery, lock/deletion protection and retained resources; preserve unrelated resources |
| family-ref fails | pin merged TX main SHA in DX and pass its platform CI |

Next session: synchronize forks, check weekly CI/CVEs/support calendars, review prices/credits/
quotas, refresh budget/expiry, recover the same bootstrap/backend state and plan again.
Follow [MAINTENANCE.md](MAINTENANCE.md) and each lab's calendar.
Public documentation stays in English; update this guide with workflow changes.

## 13. Continue to local AI and GPU infrastructure

After the AWS/Azure/Google Cloud comparison, use the [AI/GPU track](AI_GPU_TRACK.md).
You can complete the local learning route without paying for managed cloud runs in sections 4–11.
Local CPU inference is planned work, so its position in the route is a learning objective, not
an available one-command model deployment. The GPU simulation lab can be studied independently
while that lesson is being built.

The current standalone lab is [tx04v2](https://github.com/maringelix/tx04v2). On a disposable
machine with Docker Desktop, follow its [bring-up guide](https://github.com/maringelix/tx04v2/blob/main/docs/bring-up.md):

```bash
git clone https://github.com/maringelix/tx04v2.git
cd tx04v2
./lab.sh up
./lab.sh serving
./lab.sh kubectl -n serving get pods
TX04V2_ACK_DELETE_CLUSTER=tx04v2 ./lab.sh down
```

Use `lab.ps1` for the equivalent PowerShell commands. `up` can build the toolbox implicitly;
use hosted CI if the machine has other critical workloads. This deploys a mock service, not a
real language model. Inspect the [validation scope](https://github.com/maringelix/tx04v2/blob/main/docs/HARNESS.md)
before adding the optional GPU simulation, scheduling, networking or observability modules.
No cloud credentials, shared app contract or physical GPU are needed for the baseline smoke.
