# Complete scope audit — 2026-10-16

> Historical snapshot before R7–R11. See the [roadmap](../ROADMAP.md) and
> [acceptance matrix](ACCEPTANCE.md) for current implementation/evidence. Gaps below describe
> the code audited on that date; they are not a current remaining-work list.

## Conclusion and criteria

**The complete scope requested by Bruno was not yet constructed at this audit.** R0–R4 delivered
a broad foundation with local Kubernetes, app, GitOps, security and observability exercised in
Docker/CI. Earlier closure followed DEC-11, excluding several capabilities. DEC-13 reopened them:
R7–R11 planned **22 construction PRs**, beyond that documentary revision. No real v2 cloud run
was demonstrated.

The read-only audit compared six repositories' code, manifests, workflows and documented limits
against the 2026-10-16 request. It reran no tests/cloud commands. “Implemented” meant existing code;
“verified in CI” preserved recorded evidence. Docker does not prove managed controller behavior.
Sources link main; the date identifies the audited snapshot.

## Request × evidence at audit × missing delivery

| Capability | Evidence and limit at audit | Required delivery |
|---|---|---|
| EKS/AKS/GKE Autopilot | Cluster IaC existed. EKS Spot/min-max did not install node autoscaling; AKS configured autoscaling and GKE enabled Autopilot. [EKS](https://github.com/maringelix/tx01v2/blob/main/terraform/modules/eks/nodes.tf), [AKS](https://github.com/maringelix/tx02v2/blob/main/terraform/modules/aks/main.tf), [GKE](https://github.com/maringelix/tx03v2/blob/main/terraform/modules/gke/main.tf) | R10.1: measured load/scaling, EKS controller, provider Spot options |
| Three React/Node apps | Three deployments of the same Express/React/PostgreSQL app, deliberately not different products; cloud unexecuted. [AWS](https://github.com/maringelix/dx01v2/blob/main/README.md), [Azure](https://github.com/maringelix/dx02v2/blob/main/README.md), [GCP](https://github.com/maringelix/dx03v2/blob/main/README.md) | R7.2/R11.1 releases/full tracks, separate cloud status |
| IaC/network/registry/identity/Actions | Built VPC/VNet, subnets, ECR/ACR/Artifact Registry, RBAC/secrets/federation; code/contract/renders did not prove real permissions/connectivity. [AWS contract](https://github.com/maringelix/tx01v2/blob/main/docs/CONTRACT.md), [Azure](https://github.com/maringelix/tx02v2/blob/main/docs/CONTRACT.md), [GCP](https://github.com/maringelix/tx03v2/blob/main/docs/CONTRACT.md) | R8.1 coherent fork/profiles, TLS/DNS/WAF, negative IAM/boundary cases and coordinated contracts |
| ALB/Gateway/WAF/automatic TLS | Edge/WAF existed. AWS accepted supplied ACM. Azure/GCP listeners were HTTP with HTTPS planned. Local cert-manager used lab CA. [Azure Gateway](https://github.com/maringelix/dx02v2/blob/main/deploy/k8s/components/azure/gateway.yaml), [GCP](https://github.com/maringelix/dx03v2/blob/main/deploy/k8s/components/gcp/gateway.yaml) | R8.1 DNS, issuance/renewal, redirect, HTTPS smoke and offline paths |
| SonarQube/SAST/gates | eslint/tsc, Vitest/coverage, gitleaks and config/image Trivy existed; no SonarQube/dedicated SAST gate. [Checks](https://github.com/maringelix/dx01v2/blob/main/scripts/harness.sh) | R7.1 real Sonar, blocking gate, SAST/reports and negative proof |
| CI/CD/zero downtime | Same artifact build→kind tested; cloud rebuilt images. Local rollout changed tags of identical content. [CI](https://github.com/maringelix/dx01v2/blob/main/.github/workflows/ci.yml), [deploy](https://github.com/maringelix/dx01v2/blob/main/scripts/deploy-aws.sh), [limits](https://github.com/maringelix/dx01v2/blob/main/docs/LOCAL_LAB.md) | R7.2 build once/digest promotion, actual content change, compatible migration/rollback |
| GitOps/Argo CD | Revision publication, Synced/Healthy and self-heal had local evidence; DX workflows required cloud full. [Local deploy](https://github.com/maringelix/dx01v2/blob/main/scripts/deploy-local.sh), [runbook](https://github.com/maringelix/dx01v2/blob/main/docs/RUNBOOK.md) | R7.2/R8.1 release/rollback lessons and consistent core/full path |
| Advanced mesh/traffic | Local and EKS/AKS installer ambient/mTLS/policies existed; GCP omitted Istio; no complete canary/timeout/retry/circuit-breaking exercise. [GCP charts](https://github.com/maringelix/tx03v2/blob/main/platform/full/charts.txt) | R8.2 app integration/advanced traffic and supported Autopilot mesh with costs/limits |
| Observability/OTel/Cloud Monitoring | Local stack/cloud charts, correlated app traces/logs/exemplars and native exporters; GKE logging existed. App ServiceMonitor/rules/dashboard lacked equivalent cloud integration. [Local monitoring](https://github.com/maringelix/dx01v2/blob/main/deploy/k8s/components/local-platform/monitoring.yaml), [cloud component](https://github.com/maringelix/dx01v2/blob/main/deploy/k8s/components/aws/kustomization.yaml), [telemetry](https://github.com/maringelix/dx01v2/blob/main/api/src/telemetry.ts) | R8.3 integrated cloud signals/dashboards/alerts/Monitoring and optional durable retention |
| Slack/24-hour monitoring | Optional Slack receiver, local sink; no external delivery without webhook. Grafana/Tempo/Loki ephemeral with short retention. [Slack](https://github.com/maringelix/tx01v2/blob/main/platform/values/full/kube-prometheus-stack-slack.yaml), [Grafana](https://github.com/maringelix/tx01v2/blob/main/platform/local/values/kube-prometheus-stack.yaml), [Tempo](https://github.com/maringelix/tx01v2/blob/main/platform/local/values/tempo.yaml), [Loki](https://github.com/maringelix/tx01v2/blob/main/platform/local/values/loki.yaml) | R8.3 persistence/recovery/notification test; external webhook and 24/7 need operational evidence |
| Gatekeeper/Trivy runtime | Local admission/reports exercised; cloud constraints existed, but private-registry credentials missing. [Policies](https://github.com/maringelix/tx01v2/blob/main/platform/full/policies/constraints/allowed-repos.yaml), [Trivy limit](https://github.com/maringelix/tx01v2/blob/main/platform/values/full/trivy-operator.yaml) | R8.4 least-privilege registry access, private reports, deny/runtime evidence |
| PostgreSQL HA/automated backup | RDS opt-in multi-AZ default false/one-day retention. Azure lacked HA/geo backup. Cloud SQL ZONAL/no PITR/one backup deleted with instance. [RDS](https://github.com/maringelix/tx01v2/blob/main/terraform/envs/lab/variables.tf), [Azure](https://github.com/maringelix/tx02v2/blob/main/terraform/modules/postgres/main.tf), [Cloud SQL](https://github.com/maringelix/tx03v2/blob/main/terraform/modules/cloudsql/main.tf) | R9.1 explicit HA, retention/PITR/protection and restore; retain identified cheap defaults |
| Kubernetes/database backup | Velero ConfigMap restore with snapshotVolumes=false; DX pg_dump/restore. Neither proves joint PV/data recovery or cross-region DR. [Velero](https://github.com/maringelix/tx01v2/blob/main/platform/local/check.sh), [database](https://github.com/maringelix/dx01v2/blob/main/scripts/e2e-platform.sh) | R9.1/R9.2 scheduled backup, applicable volumes, isolated restore/integrated recovery |
| Multi-region DR | not implemented; excluded by reduced scope | R9.2 independent local B, cloud DR IaC, failover/failback and exercise RTO/RPO |
| Chaos Engineering | Local pod/latency/stress hypotheses and app availability/spans; GCP cloud pod-kill only. [Local](https://github.com/maringelix/tx01v2/blob/main/platform/local/check.sh), [GCP](https://github.com/maringelix/tx03v2/blob/main/platform/values/full/chaos-mesh.yaml) | R8.4/R9.2/R10.1 portable node/region-loss/recovery exercises and supported Autopilot alternatives |
| FinOps/optimization | Budgets/cost docs/EKS Spot existed; no OpenCost/showback/VPA/measured HPA load or coordinated AKS/GKE Spot. [AWS costs](https://github.com/maringelix/tx01v2/blob/main/docs/COSTS.md), [Azure](https://github.com/maringelix/tx02v2/blob/main/docs/COSTS.md), [GCP](https://github.com/maringelix/tx03v2/blob/main/docs/COSTS.md) | R10.1/R10.2 measured capacity/cost, VPA recommendation, budgets/limits, before/after |

## Two fork paths needed alignment

The historical [AWS FORK](https://github.com/maringelix/tx01v2/blob/main/FORK.md) described DX push
for core while [deploy workflow](https://github.com/maringelix/dx01v2/blob/main/.github/workflows/deploy-aws.yml)
fixed DEPLOY_MODE=gitops. DX runbooks for
[AWS](https://github.com/maringelix/dx01v2/blob/main/docs/RUNBOOK.md),
[Azure](https://github.com/maringelix/dx02v2/blob/main/docs/RUNBOOK.md) and
[GCP](https://github.com/maringelix/dx03v2/blob/main/docs/RUNBOOK.md) required full for GitOps,
while platform defaulted to core.

R8.1 needed both coherent paths: documented core push and full Argo/GitOps. Each fork configures
its own identities, variables, environments, domains and integrations; external settings are not copied.

## Free SonarQube without commercial feature promises

The audit required reproducible Community Build/main analysis and a blocking gate, without
commercial native multibranch/PR-decoration assumptions. Gate failure must fail the workflow
through a quality-gate check or sonar.qualitygate.wait=true.
[Official integration](https://docs.sonarsource.com/sonarqube-community-build/devops-platform-integration/github-integration/adding-analysis-to-github-actions-workflow).

PR SAST needed a free reproducible path without upstream secrets. Fork owners could optionally
configure SonarQube Cloud subject to Free/OSS plan conditions.
[Official plans](https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-subscription/subscription-plans).
Document separate licenses for pinned
[core](https://github.com/SonarSource/sonarqube/blob/master/README.md) and
[JavaScript analyzer](https://raw.githubusercontent.com/SonarSource/SonarJS/master/LICENSE.txt).
Quality analysis does not replace other scanners or negative cases.

## GKE Autopilot remains in scope

R8.2 required supported Autopilot configuration/IaC, policies, traffic and corresponding exercises.
Google's documented path used managed Cloud Service Mesh rather than an in-cluster control plane.
Missing ambient was a limitation to resolve, not completion of mesh.
[Supported platforms](https://docs.cloud.google.com/service-mesh/docs/supported-platforms).

## Construction plan: 22 PRs

| Round | IDs/outcome | Planned PRs |
|---|---|---:|
| R7 DevSecOps/releases | R7.1 gates/Sonar/SAST; R7.2 digest/release/migration/rollback | 3 DX |
| R8 integrated platform | R8.1 edge/forks; R8.2 mesh; R8.3 observability; R8.4 runtime/Chaos | 3 TX + 3 DX |
| R9 data/recovery | R9.1 HA/backup/PITR; R9.2 multi-region DR | 3 TX + 3 DX |
| R10 capacity/FinOps | R10.1 scaling/load/Spot; R10.2 costs/OpenCost/VPA | 3 TX + 3 DX |
| R11 acceptance/learning | R11.1 curriculum/evidence/limits/complete cloud tracks | 1 hub |
| **Total** | one cohesive PR per repository/round, with docs/lessons | **22** |

This estimate grouped outcomes, subject to real incompatibilities; it did not allocate a PR per
tool. Planning docs were not implementation. All DX retain app parity; TX/DX coordinate/version contracts.

## Checkable definition of complete

- Every technology has executable configuration, prerequisites, lesson, expected result,
  deliberate failure, recovery, costs and cleanup; the matrix links checks/PRs.
- CI blocks regressions and proves failed gates prevent promotion; delivery uses approved digests
  and measures availability during actual content changes/rollback.
- Backup/DR recovers verifiable data; RPO uses transactions/timestamps and RTO includes failure,
  recovery and stabilization. Failback/reconciliation are part of the drill.
- Docker simulates independent regions, not geographic isolation, SLA, managed failover or
  production RTO/RPO.
- FinOps distinguishes estimates/simulations from invoices. Include HA, second region,
  replication/egress, retention, observability, DNS/LB/WAF/NAT/IP. Budgets alert, not cap.
- Cheap profiles remain entry points; full/HA/DR have explicit costs. DEC-12 keeps small at 7 GB;
  new profiles publish memory/time requirements.
- Docker/renders/mocks/Actions can close construction; real validation needs a separately
  authorized provider run/account/budget and retains its own state.
- Merged PRs alone do not establish production, 24/7, optimized bills or complete scope.
  DEC-13 closes only with R7–R11 acceptance and the complete matrix.
