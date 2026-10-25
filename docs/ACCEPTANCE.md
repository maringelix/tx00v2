# Lab construction acceptance matrix

Delivered cloud scope: DEC-13, R7–R11, 22 PRs (21 implementation PRs plus hub closure).
The broader [learning path](LEARNING_PATH.md), accepted under DEC-15, reuses this evidence;
it does not count planned beginner lessons or AI/GPU capabilities as delivered by those PRs.
The [curriculum](CURRICULUM.md) gives prerequisites, objectives, commands, induced failures,
acceptance, diagnosis, recovery, costs and cleanup. The [roadmap](../ROADMAP.md) records PRs.
Use [GETTING_STARTED.md](GETTING_STARTED.md) for the complete operating sequence.

Construction and execution have separate states. The three-cloud IaC/app code is tested through
mocks, Docker and kind in Actions. No v2 path has been validated in a real cloud account.

## Requirement × implementation × evidence × limit

| Requirement | AWS | Azure | Google Cloud | Construction/CI evidence and limit | Rounds/PRs |
|---|---|---|---|---|---|
| Three Kubernetes platforms | EKS | AKS | GKE Autopilot | IaC/mocked providers and real kind; managed control planes unexecuted | R8/R10 |
| Full-stack app | dx01v2 | dx02v2 | dx03v2 | intentionally same React/Express/Node/PostgreSQL; unit/integration/image/smoke/e2e | R7/R8 |
| Terraform/network | VPC/public-private subnets/NAT | VNet/subnets/CNI Overlay/Cilium | VPC/private nodes/PSC/Cloud SQL | negative validation for open/overlapping inputs; no account routing evidence | R8/R9 |
| State/IaC | S3/KMS/versioning | Blob/locks/versioning | GCS/versioning | separate protected/versioned state, opt-in recovery/retention; no automatic backend failover | R9 |
| Identity/least privilege | OIDC/EKS Pod Identity | OIDC/Entra Workload ID | WIF/KSA principals | tested trust/scopes/conditions/boundary/ABAC/contracts; no static keys | R8/R9 |
| Registry | ECR | ACR | Artifact Registry | digest artifacts/contracts; no registry credential stored in the app | R7/R9 |
| CI/CD/security | GitHub Actions | same | same | required harness/coverage, real CodeQL/Trivy/gitleaks/SonarQube/ZAP and negative fixtures | R7 |
| SonarQube/SAST | Community Build/quality gate | same | same | isolated analysis and gate result; no commercial multibranch dependency | R7 |
| Artifact chain | SBOM/provenance/keyless signing | same | same | SHA/checksum/identity/issuer verification, no-rebuild promotion, tampering rejected | R7/R8 |
| GitOps/deploy | Argo CD | Argo CD | Argo CD | changed-content rollout, continuous traffic, readiness failure/rollback; no universal zero-error promise | R7/R8 |
| Load balancing/DNS | ALB/Route53 | AGC/Azure DNS | Gateway/Cloud DNS | contracts/manifests/IAM, local Gateway HTTPS, regional smoke forcing target before DNS | R8/R9 |
| Automatic TLS | ACM | cert-manager/ACME | Certificate Manager | local CA/SNI/redirect; real public issuance/renewal needs cloud evidence | R8/R9 |
| WAF | AWS WAF | AGC WAF | Cloud Armor | IaC/contracts/rule association; each native engine needs its own validation | R8 |
| Mesh/traffic | Istio ambient | Istio ambient | managed Cloud Service Mesh/sidecars | kind mTLS/identity/canary/retry/outlier/isolation; no privileged ambient daemon on Autopilot | R8 |
| Metrics/alerts | stack + AWS integrations | stack + Application Insights | stack + Cloud Trace/Monitoring | targets/SLO rules, synthetic HTTP receiver/Slack emulator; native export checked as configuration | R8 |
| OTel/logs | Collector/X-Ray/Loki/Tempo | Collector/App Insights/Loki/Tempo | Collector/Cloud Trace/Loki/Tempo | edge→API→SQL traces and correlated logs/exemplars; PVC/retention code, no 24/7 operational claim | R8 |
| Runtime policies | Gatekeeper/OPA/Kyverno/PSA/NetworkPolicy | same | Autopilot-compatible set | invalid pod/identity/artifact denial and scan reports; gates remain enabled | R8 |
| PostgreSQL HA | opt-in RDS multi-AZ | opt-in ZoneRedundant Flexible Server | opt-in regional Cloud SQL | tested economical/HA/DR profiles; kind does not prove managed failover | R9 |
| Backup/PITR | RDS + local physical backup | native + local physical backup | Cloud SQL + local physical backup | basebackup/WAL/restore point, corruption denial, correct data/reconnect; native PITR needs cloud run | R9 |
| Volume backup | Velero FSB/Kopia/S3 | Velero FSB/Kopia/Blob | Velero CSI/Persistent Disk/GCS | original PVC bytes deleted, new claim/checksum recovery; native CSI/storage unexecuted | R9 |
| Multi-region DR | secondary runtime/network/DB/ECR/secrets/backup | secondary runtime/network/DB/ACR/vault/config | secondary runtime/network/DB/registry/secrets/config | two-region IaC, independent Docker A/B, fencing/total loss/RPO/RTO/failback; no auto-promotion | R9 |
| Chaos | pod/network/CPU/memory | same | PodChaos without privileged daemon; mesh HTTP failure/latency | kind hypotheses/SLO/recovery; smaller Autopilot surface explicitly documented | R8/R10 |
| Node autoscaling | real CA/ASG discovery tags | managed autoscaler enabled | Autopilot capacity from requests | IaC/IAM/minor compatibility; managed node up/down unexecuted | R10 |
| Spot/fallback | optional tainted Spot pool/on-demand baseline | tainted user Spot pool/regular system | finite Spot Job/on-demand alternative | local drain/PDB/rescheduling; no Spot availability/discount guarantee | R10 |
| HPA/load | same app scenario | same | same | HPA up/down, Gateway SLO, quota denial, PostgreSQL pool saturation/recovery | R10 |
| FinOps | OpenCost/reviewed AWS rates | reviewed Azure rates | reviewed GCP rates | measured allocation/owner/environment/idle/shared/external costs; deterministic fixtures are not quotes | R10 |
| Rightsizing | VPA Off | VPA Off | managed VPA Off | recommendations without mutation; before/after requests/replicas/SLO; no inferred billed savings | R10 |
| Budget/expiry/cleanup | TX gate/inventory | same | same | private plan, complete rates, estimated limit, <=24-hour expiry, load deadline, teardown/leftovers; budget not billing cap; manual cloud destroy | R10 |
| Fork/parity | contract v7 | contract v5 | contract v5 | clean CI without cloud secrets; family checks contracts/pins/versions/digests/app; no second real GitHub account rehearsal | R7/R8/R9/R10/R11 |

## Executable sources

| Layer | AWS | Azure | GCP |
|---|---|---|---|
| Infrastructure/profiles | [tx01v2](https://github.com/maringelix/tx01v2/tree/main/terraform) | [tx02v2](https://github.com/maringelix/tx02v2/tree/main/terraform) | [tx03v2](https://github.com/maringelix/tx03v2/tree/main/terraform) |
| Cloud/local platform | [platform](https://github.com/maringelix/tx01v2/tree/main/platform) | [platform](https://github.com/maringelix/tx02v2/tree/main/platform) | [platform](https://github.com/maringelix/tx03v2/tree/main/platform) |
| App/overlays/probes | [dx01v2](https://github.com/maringelix/dx01v2) | [dx02v2](https://github.com/maringelix/dx02v2) | [dx03v2](https://github.com/maringelix/dx03v2) |
| Continuity | [TX runbook](https://github.com/maringelix/tx01v2/blob/main/docs/CONTINUITY.md) | [TX runbook](https://github.com/maringelix/tx02v2/blob/main/docs/CONTINUITY.md) | [TX runbook](https://github.com/maringelix/tx03v2/blob/main/docs/CONTINUITY.md) |
| Capacity/FinOps | [TX runbook](https://github.com/maringelix/tx01v2/blob/main/docs/FINOPS.md) | [TX runbook](https://github.com/maringelix/tx02v2/blob/main/docs/FINOPS.md) | [TX runbook](https://github.com/maringelix/tx03v2/blob/main/docs/FINOPS.md) |

Roadmap PR links are checked against merged main commits. CI links refer to specific revisions;
verified in CI describes those tests, without implying validation in three clouds.

## Construction PRs by round

The final matrix column refers to these PRs. [DELIVERIES.json](DELIVERIES.json) is the
machine-readable ledger; R11 is this hub's closure.

| Round | AWS | Azure | Google Cloud |
|---|---|---|---|
| R7 | [dx01v2#17](https://github.com/maringelix/dx01v2/pull/17) | [dx02v2#12](https://github.com/maringelix/dx02v2/pull/12) | [dx03v2#14](https://github.com/maringelix/dx03v2/pull/14) |
| R8 | [tx01v2#16](https://github.com/maringelix/tx01v2/pull/16), [dx01v2#18](https://github.com/maringelix/dx01v2/pull/18) | [tx02v2#14](https://github.com/maringelix/tx02v2/pull/14), [dx02v2#13](https://github.com/maringelix/dx02v2/pull/13) | [tx03v2#15](https://github.com/maringelix/tx03v2/pull/15), [dx03v2#15](https://github.com/maringelix/dx03v2/pull/15) |
| R9 | [tx01v2#17](https://github.com/maringelix/tx01v2/pull/17), [dx01v2#19](https://github.com/maringelix/dx01v2/pull/19) | [tx02v2#17](https://github.com/maringelix/tx02v2/pull/17), [dx02v2#14](https://github.com/maringelix/dx02v2/pull/14) | [tx03v2#16](https://github.com/maringelix/tx03v2/pull/16), [dx03v2#16](https://github.com/maringelix/dx03v2/pull/16) |
| R10 | [tx01v2#18](https://github.com/maringelix/tx01v2/pull/18), [dx01v2#20](https://github.com/maringelix/dx01v2/pull/20) | [tx02v2#18](https://github.com/maringelix/tx02v2/pull/18), [dx02v2#15](https://github.com/maringelix/dx02v2/pull/15) | [tx03v2#17](https://github.com/maringelix/tx03v2/pull/17), [dx03v2#17](https://github.com/maringelix/dx03v2/pull/17) |
| R11 | TX00 closure: curriculum, matrix and family checks | Same hub | Same hub |

## Cloud validation

Future execution checklist for the fork owner; the [central guide](GETTING_STARTED.md) provides
the account/bootstrap/secret/workflow sequence.

1. Choose one provider at a time, a dedicated account/project and bounded window. Check account
   credit/service/region limits; do not assume full/HA/DR fits a free tier.
2. Configure forks, rulesets, protected lab and OIDC; enable Actions, align the pair's TX01V2_REPO,
   TX02V2_REPO or TX03V2_REPO URL/pin and pass CI.
3. Review regional prices, maximum SKU/DR, budget/duration/expiry, owned DNS/domain/webhook.
   Preserve backup repository keys where required.
4. Bootstrap, review plan, apply, install platform and promote through existing workflows,
   staying inside lab names/scopes.
5. Record public TLS, WAF, federation, native telemetry/Slack, retention, managed node scaling,
   Spot/fallback and actual costs.
6. Rehearse isolated backup/PITR and fenced DR. Verify data markers/version/certificate/destination
   before cutover, measure RPO/RTO and exercise failback.
7. Destroy at the window's end; inventory both regions and retained resources/versions/snapshots/keys.
   Retention has separate costs and operator decisions.
8. Submit sanitized cloud_run_report with successes/failures. Fix discovered defects through new
   PRs without rewriting historical local evidence.

## Maintenance

Construction closure does not end CVE/pin/Kubernetes/provider/chart upkeep, price freshness,
quota/certificate checks, backup age/replica lag or retention. Follow each repository's
docs/MAINTENANCE.md and weekly hub CI. Domains, accounts and continuous operation belong to
the fork owner.

## AI and GPU track

This inventory is separate from the historical R7–R11 cloud ledger. The
[track guide](AI_GPU_TRACK.md) maps it to prerequisites and missing work.

| Capability | Current material or evidence | Limit / next acceptance |
|---|---|---|
| Sequential foundations and architecture route | [learning path](LEARNING_PATH.md), with existing A01–A17 reused for cloud practice | beginner guided lesson packs and assessed architecture exercises are planned in R12.1 |
| Independent local lab | [tx04v2](https://github.com/maringelix/tx04v2), [baseline CI](https://github.com/maringelix/tx04v2/actions/runs/40182267072), revision `ff936c9c38c2652c331458b5fe1f0a6bb0ff28b3` | `verified in CI`: toolbox build, default kind, mock health/request/metrics and teardown; not all optional modules |
| Static configuration, launcher boundary and GPU alert | the same baseline CI validates YAML/Kubernetes, Bash/PowerShell, shell launcher contract, dashboard PromQL and synthetic alert transitions | syntax/configuration and synthetic-series evidence do not establish live GPU wiring |
| Simulated GPU, Volcano, KWOK and incident modules | manifests, installers and runbooks in tx04v2 | R12.3 must add guided checkpoints, reproducible optional downloads and module runtime evidence |
| Real local CPU inference | reference notes/manifests exist; the CPU image path is incomplete | `planned`: R12.2 requires a supported pinned runtime/model, real generation and repeatable measurements |
| Physical GPU infrastructure | introductory hardware notes and a time-slicing configuration | `planned`: R12.4 needs compatible hardware, driver/runtime evidence, actual memory/error/isolation and multi-GPU exercises |
| Integrated inference capstone | objectives in the learning path and AI/GPU guide | `planned`: R12.5 requires a reproducible release, measurements, incident/recovery report and cleanup |

The baseline commit starts a new repository and is not a merged PR for closing R12 items.
Future completed roadmap items still require the merged-PR evidence enforced by the hub.
Do not label fake GPU telemetry, a mock response or a scheduler-only node as model execution,
CUDA performance, VRAM measurements or completed distributed training.
