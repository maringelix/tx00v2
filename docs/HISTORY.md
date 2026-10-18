# v2 family history

Completed work in order, with merged PRs (merge dates in UTC). family-evidence checks every PR
listed here against its repository's main. Remaining work is in [ROADMAP.md](../ROADMAP.md).

## Before v2

The v1 repositories tx01–tx03/dx01–dx03 and private audit hub tx00 ran in AWS, Azure and Google
Cloud while credits lasted, with manual platform workflows. Their lessons are preserved in
each v2 TX docs/LESSONS_LEARNED.md. v1 repositories are private and were archived on 2026-10-12;
v2 has no dependency on them.

## 2026-10-10 to 2026-10-12: six repositories (R0.1, R0.2)

- AWS TX/DX started with harness, CI, guardrails and docs. The first green CI enabled verified-in-CI
  labels; DX01#3 also adjusted Dependabot ranges.
- Azure ported the reference pair with provider-specific requirements. AWS TX01#2/DX01#4 added
  family tables and app parity.
- GCP followed; TX01#3/TX02#2 added GCP family entries. DX01#5/DX02#2/DX03#4 ported Google's
  X-Forwarded-For test and ignored unsupported Node major bumps in Dependabot.
- All six became public with repo-guardrails.sh applied; v1 was archived.

Merged PRs: [tx01v2#1](https://github.com/maringelix/tx01v2/pull/1), [dx01v2#3](https://github.com/maringelix/dx01v2/pull/3), [tx02v2#1](https://github.com/maringelix/tx02v2/pull/1), [dx02v2#1](https://github.com/maringelix/dx02v2/pull/1), [tx01v2#2](https://github.com/maringelix/tx01v2/pull/2), [dx01v2#4](https://github.com/maringelix/dx01v2/pull/4), [tx03v2#1](https://github.com/maringelix/tx03v2/pull/1), [tx03v2#2](https://github.com/maringelix/tx03v2/pull/2), [dx03v2#3](https://github.com/maringelix/dx03v2/pull/3), [tx01v2#3](https://github.com/maringelix/tx01v2/pull/3), [tx02v2#2](https://github.com/maringelix/tx02v2/pull/2), [dx01v2#5](https://github.com/maringelix/dx01v2/pull/5), [dx02v2#2](https://github.com/maringelix/dx02v2/pull/2), [dx03v2#4](https://github.com/maringelix/dx03v2/pull/4).

## 2026-10-13: full local v1 platform (R0.3)

Kind and local cloud equivalents hosted Istio ambient, cert-manager, ESO, Prometheus,
Alertmanager, Grafana, Loki, Argo CD, Gatekeeper, Trivy Operator, Velero and Chaos Mesh.
Probes exercised the platform and GitOps app. TX01#6 allowed teardown after a Gateway Service
had already disappeared. All three TX and DX received the platform/app path.

Merged PRs: [tx01v2#5](https://github.com/maringelix/tx01v2/pull/5), [tx01v2#6](https://github.com/maringelix/tx01v2/pull/6), [tx02v2#3](https://github.com/maringelix/tx02v2/pull/3), [tx02v2#4](https://github.com/maringelix/tx02v2/pull/4), [tx03v2#3](https://github.com/maringelix/tx03v2/pull/3), [dx01v2#6](https://github.com/maringelix/dx01v2/pull/6), [dx02v2#3](https://github.com/maringelix/dx02v2/pull/3), [dx03v2#5](https://github.com/maringelix/dx03v2/pull/5).

## 2026-10-14: local lab merge gates and forks (R0.4, R0.5)

- e2e/e2e-platform became required ruleset checks in all pairs.
- FORK.md, bootstrap without default owner, fork-aware repo-guardrails.sh and DX e2e-platform
  cloning the configured TX repository were delivered.

Merged PRs: [tx01v2#7](https://github.com/maringelix/tx01v2/pull/7), [dx01v2#7](https://github.com/maringelix/dx01v2/pull/7), [tx02v2#5](https://github.com/maringelix/tx02v2/pull/5), [dx02v2#4](https://github.com/maringelix/dx02v2/pull/4), [tx03v2#4](https://github.com/maringelix/tx03v2/pull/4), [dx03v2#6](https://github.com/maringelix/dx03v2/pull/6), [tx01v2#8](https://github.com/maringelix/tx01v2/pull/8), [dx01v2#8](https://github.com/maringelix/dx01v2/pull/8), [tx02v2#6](https://github.com/maringelix/tx02v2/pull/6), [dx02v2#5](https://github.com/maringelix/dx02v2/pull/5), [tx03v2#5](https://github.com/maringelix/tx03v2/pull/5), [dx03v2#7](https://github.com/maringelix/dx03v2/pull/7).

## 2026-10-14: round 1, Observability 2.0, alerts, Chaos and rollout (R1)

Contracts became v2 with the Collector OTLP endpoint.

- TX added local Collector/Tempo, Istio Gateway spans, spanmetrics/exemplars, Grafana signal
  links, Slack receiver, latency/stress Chaos and native exporter code for X-Ray,
  Application Insights and Cloud Trace.
- DX added manual API spans, trace_id logs, exemplars, continuous-request rollout and
  API/database latency exercises.
- CI found a 15-second exemplar lifetime, requiring a 10-second ServiceMonitor; Gateway→Collector
  needed HBONE 15008 because the Collector is in the mesh. Trivy server installation failed once
  (R1.9). DX03 check-manifests.mjs needed the new Collector NetworkPolicy in its exact GCP list.
  Locally TX03 ESO webhook timed out twice while CI passed (R1.10).

Merged PRs: [tx01v2#9](https://github.com/maringelix/tx01v2/pull/9), [tx02v2#7](https://github.com/maringelix/tx02v2/pull/7), [tx03v2#6](https://github.com/maringelix/tx03v2/pull/6), [dx01v2#9](https://github.com/maringelix/dx01v2/pull/9), [dx02v2#6](https://github.com/maringelix/dx02v2/pull/6), [dx03v2#8](https://github.com/maringelix/dx03v2/pull/8).

## 2026-10-14: hub (R0.6)

The hub added reference navigation, complete-scope roadmap, family guardrails and cross-repository
harness checks.

- Round-1 TX03/DX02/DX03 PRs and documentation PRs TX01#10/DX01#10/TX02#8 added the hub table row.
  DX01#10 also fixed a stale check-manifests comment.
- TX02#8/TX03#7 corrected docs still calling the complete local run planned.
- Every family invariant held except a documented kubectl difference: TX 1.37.1/DX 1.36.5, S.2.
- First hub CI passed static 9/9 and family 11/11 against six mains. Guardrails applied the
  required-static ruleset, secret scanning/push protection, private vulnerability reporting
  and fork-run approval; gh api confirmed settings.

Merged PRs: [tx01v2#10](https://github.com/maringelix/tx01v2/pull/10), [dx01v2#10](https://github.com/maringelix/dx01v2/pull/10), [tx02v2#8](https://github.com/maringelix/tx02v2/pull/8), [tx03v2#7](https://github.com/maringelix/tx03v2/pull/7).

## 2026-10-14: scripts restricted to lab resources (R0.7)

A read-only safety audit found scripts choosing targets from generic environment variables or
the current kubectl context. platform/uninstall.sh deletes Ingress, Gateway and LoadBalancer
Services in its target cluster; an unrelated exported CLUSTER_NAME could redirect it.
App integration tests drop tables in the DB_* database while development runbooks exported the
development database.

- All six repositories received target/context/database guards.
- Before PRs, policy-scripts matched its own grep line and TX01's kubeconfig-output test still
  expected the old command. The pinned Google provider schema confirmed default_labels enter
  terraform_labels, allowing the project-label guard to recognize its own cluster.
- Remaining audit findings became R3.13–R3.18.

Merged PRs: [tx01v2#11](https://github.com/maringelix/tx01v2/pull/11), [tx02v2#9](https://github.com/maringelix/tx02v2/pull/9), [tx03v2#8](https://github.com/maringelix/tx03v2/pull/8), [dx01v2#11](https://github.com/maringelix/dx01v2/pull/11), [dx02v2#7](https://github.com/maringelix/dx02v2/pull/7), [dx03v2#9](https://github.com/maringelix/dx03v2/pull/9).

## 2026-10-15: debt round (R1.7, R1.10, S.8)

- R1.7: TX01 installs the Collector from an archive verified against
  OTEL_COLLECTOR_CHART_SHA256 in platform/versions.env, matching Azure/GCP; previously cloud
  installation trusted the chart repository without verifying the archive.
- R1.10: local TX03 inherited Autopilot ESO 50m CPU ceilings through layered Helm values.
  Local values remove webhook/cert-controller resources and set a 1-CPU controller ceiling.
  A nested null absent from chart defaults rendered literally as cpu: null.
  Three consecutive observability runs passed 22/22 probes on 7.65 GiB Docker Desktop.
- S.8: about 150 contract-v1 references became version-neutral contract/doc links or v2 where
  relevant. Historical changelogs, dated DX02 contract notes and old-platform troubleshooting
  intentionally retained v1. HTTPS was outside contract v2 at that time.
- R1.9 remained pending at this checkpoint: the single pre-diagnostics Trivy failure had not
  recurred; AWS had eight consecutive successes against the ten-run target.
- Validation found a DX03 Prettier line exceeding 120 columns and the literal cpu: null render.

Merged PRs: [tx01v2#12](https://github.com/maringelix/tx01v2/pull/12), [tx03v2#9](https://github.com/maringelix/tx03v2/pull/9), [tx02v2#10](https://github.com/maringelix/tx02v2/pull/10), [dx01v2#12](https://github.com/maringelix/dx01v2/pull/12), [dx02v2#8](https://github.com/maringelix/dx02v2/pull/8), [dx03v2#10](https://github.com/maringelix/dx03v2/pull/10).

## 2026-10-15: local small size (R1.8)

- LOCAL_SIZE=small layers platform/local/values/small/<chart>.yaml last. Changes include lower
  limits/GOMEMLIMIT, shorter Prometheus/Tempo retention, removed cAdvisor series/apiserver
  histograms, fewer Argo workers, one Trivy scan and Gatekeeper audits limited to constraint kinds.
  kind-config-small.yaml adds control-plane GOMEMLIMIT. DX gained no-swap DinD e2e-platform-small.
- Measurement: the initial 6–7 GB DinD attempt froze the i5/16 GB Windows development host.
  Heavy runs moved to Actions. The default size thrashed at 7 GB locally. Initial small failed
  at 6 GB (4.63 GiB anonymous memory, unhealthy app); after control-plane/Gatekeeper tuning,
  14/18 probes passed at 6 GB and all passed at 7/8 GB.
- Bruno chose 7 GB below the host's 7.65 GiB Docker allowance. Reaching 6 GB required changing
  platform behavior such as Gatekeeper auditing/apiserver watch cache to save another 1 GB.
- GOMEMLIMIT did not contain the 1.2 GiB apiserver with all CRDs. In two of nine 7 GB runs the
  kernel killed the Velero plugin-copy init container, retried by kubelet. Jobs report OOM kills
  while probes remain the gate. Shellcheck caught a backtick in printf and avoidable sed.
- R1.9 closed: consecutive green e2e counts reached AWS 11, Azure 20, GCP 18 without recurrence.

Merged PRs: [tx01v2#13](https://github.com/maringelix/tx01v2/pull/13), [dx01v2#13](https://github.com/maringelix/dx01v2/pull/13), [tx02v2#11](https://github.com/maringelix/tx02v2/pull/11), [dx02v2#9](https://github.com/maringelix/dx02v2/pull/9), [tx03v2#10](https://github.com/maringelix/tx03v2/pull/10), [dx03v2#11](https://github.com/maringelix/dx03v2/pull/11).

## 2026-10-15: fork-ready scope (DEC-11)

- The roadmap had about 19 rounds/~100 PRs by combining real cloud runs, DR, FinOps, extra
  security/quality and proposals. Bruno defined ready as fork owners running Docker/their own
  clouds without claiming real cloud validation.
- Two rounds remained: R3 fork safety and R4 full cloud platform as code plus fork onboarding.
  Removed item texts remain in ROADMAP.md at commit 736bbb7.
- Local DR was explicitly excluded to close that scope in two rounds.

## 2026-10-15 and 2026-10-16: R3 fork safety

- One PR per repository, TX before DX. DX01#15 corrected its pin to the merged TX commit;
  TX03#12 completed GCP R3.16 on 2026-10-16.
- Added immutable GitHub subjects, fail-closed guardrails, AWS boundary, narrower plan roles,
  element-wise masked operator/address secrets, destroy continuation, lab-only leftovers,
  local preflight and GCP apply without Editor.
- CI found unquoted local-lab expansion, a trap-only test function, a local-deploy loop counter,
  AWS network/port defaults accidentally copied to Azure/GCP, a race reading an old Deployment
  tag, gitleaks generic-api-key false positive in a role-ID assertion, and jq -e failing on empty
  mask lists. All were corrected.
- GCP apply roles could not be name-scoped to not-yet-created resources; the dedicated project
  and preflight bound the remaining risk (R3.16 revision of 2026-10-16).
- Evidence is harness/mocked-provider/CI execution; no real cloud run occurred.

Merged PRs: [tx01v2#14](https://github.com/maringelix/tx01v2/pull/14), [dx01v2#14](https://github.com/maringelix/dx01v2/pull/14), [tx02v2#12](https://github.com/maringelix/tx02v2/pull/12), [dx02v2#10](https://github.com/maringelix/dx02v2/pull/10), [tx03v2#11](https://github.com/maringelix/tx03v2/pull/11), [dx03v2#12](https://github.com/maringelix/dx03v2/pull/12), [dx01v2#15](https://github.com/maringelix/dx01v2/pull/15), [tx03v2#12](https://github.com/maringelix/tx03v2/pull/12).

## 2026-10-16: R4 full platform as code and fork path

- Platform TX PRs preceded matching DX GitOps PRs. TX03#14 additionally aligned its contract
  with Application/Argo refresh permission. DX pinned merged TX; contracts became AWS v4,
  Azure/GCP v3.
- TX added pinned core/full charts/images, provider overlays, Argo CD/app-of-apps, Gatekeeper,
  Trivy Operator, private Velero storage/35-day lifecycle, sizing and costs. Core remained
  default. Historical DX workflows committed cloud GitOps revisions without a push mode input;
  local scripts kept push fallback.
- Autopilot excluded ambient, node-exporter, Trivy node collector and privileged Chaos daemon.
  Supported components/experiments were documented.
- CI checked full renders, manifests, GitOps charts, mocked Terraform, kubeconform, gator and
  local DX e2e. No cloud resources/apps were created; not run in the cloud (v2) remained.
- GCP workflow policy allowed contents: write only in protected deploy; global contents stayed read.
- family-digests originally compared different provider Velero plugin digests at the same path.
  It now merges base/overlay as Helm does, enforcing one effective server and exactly the correct
  version/digest-pinned provider plugin. Other file/global image comparisons remain.

Merged PRs: [tx01v2#15](https://github.com/maringelix/tx01v2/pull/15), [dx01v2#16](https://github.com/maringelix/dx01v2/pull/16), [tx02v2#13](https://github.com/maringelix/tx02v2/pull/13), [dx02v2#11](https://github.com/maringelix/dx02v2/pull/11), [tx03v2#13](https://github.com/maringelix/tx03v2/pull/13), [dx03v2#13](https://github.com/maringelix/dx03v2/pull/13), [tx03v2#14](https://github.com/maringelix/tx03v2/pull/14).

## 2026-10-16: complete scope audit and reopening (DEC-13)

- Bruno requested the full technology/practice list across three pairs. The read-only audit
  compared Terraform, manifests, workflows, scripts and docs without cloud execution.
- DEC-11 had closed a reduced scope; remaining DevSecOps, release promotion, integration/TLS/
  mesh, data/HA/DR and FinOps gaps are in the [dated audit](SCOPE_AUDIT_2026-10-16.md).
- R7–R11 added 11 items grouped into 22 planned PRs (3 + 6 + 6 + 6 + 1) after roadmap revision.
  Planning delivered no capability; cloud validation/future fixes retained separate states.

## 2026-10-16 to 2026-10-17: R7 DevSecOps and releases

- Three construction PRs added disposable SonarQube Community Build, real gate/negative fixture,
  CodeQL/SAST, ZAP, Trivy/gitleaks/coverage, SBOM/provenance/keyless signatures.
  Promotion verifies revision/checksum/identity without rebuilding.
- Local releases changed content, exercised expand/contract migration, continuous traffic,
  unready-version failure and known-content rollback. These tests imply no cloud publication/deploy.

Merged PRs: [dx01v2#17](https://github.com/maringelix/dx01v2/pull/17), [dx02v2#12](https://github.com/maringelix/dx02v2/pull/12), [dx03v2#14](https://github.com/maringelix/dx03v2/pull/14).

## 2026-10-17: R8 integrated platform in three clouds

- Six construction PRs delivered DNS/TLS/WAF contracts, core/full paths, IAM/identity review,
  retained app observability, admission/policies/private scanning.
- L7 mesh and Chaos have portable exercises and provider-specific limits; Autopilot uses a
  supported managed mesh without privileged ambient.
- CI measures canary/retry/outlier, rejects unauthorized identities, correlates signals and
  tests recovery. Managed providers/native WAF/public TLS remain unexecuted.
  Additional Azure TX02#15/#16 fixes preserved gates and are outside the original 22 count.

Merged PRs: [tx01v2#16](https://github.com/maringelix/tx01v2/pull/16), [dx01v2#18](https://github.com/maringelix/dx01v2/pull/18), [tx02v2#14](https://github.com/maringelix/tx02v2/pull/14), [dx02v2#13](https://github.com/maringelix/dx02v2/pull/13), [tx03v2#15](https://github.com/maringelix/tx03v2/pull/15), [dx03v2#15](https://github.com/maringelix/dx03v2/pull/15), [tx02v2#15](https://github.com/maringelix/tx02v2/pull/15), [tx02v2#16](https://github.com/maringelix/tx02v2/pull/16).

## 2026-10-17: R9 data continuity

- Six construction PRs delivered opt-in HA/PITR/DR IaC, regional runtimes/contracts and restricted
  private copying of current credentials. AWS uses RDS/ECR replicas and secondary backups;
  Azure uses replica/ACR, recovery reads/Kopia escrow; GCP uses Cloud SQL replicas, multi-region
  backup storage and CSI.
- Real local exercises: physical backup/WAL to a known point, corruption rejection, deleted
  original volume bytes/new PVC checksum recovery, independent A/B networks/volumes, refusal
  to promote with a live primary, total loss, measured RPO/RTO and failback preserving B writes.
  CI does not execute managed-service failover.

Merged PRs: [tx01v2#17](https://github.com/maringelix/tx01v2/pull/17), [dx01v2#19](https://github.com/maringelix/dx01v2/pull/19), [tx02v2#17](https://github.com/maringelix/tx02v2/pull/17), [dx02v2#14](https://github.com/maringelix/dx02v2/pull/14), [tx03v2#16](https://github.com/maringelix/tx03v2/pull/16), [dx03v2#16](https://github.com/maringelix/dx03v2/pull/16).

## 2026-10-17: R10 capacity and FinOps

- Six construction PRs added real EKS Cluster Autoscaler with Pod Identity/discovery tags,
  AKS autoscaler and Spot/taints/fallback per cloud; internal OpenCost, reviewed regional prices,
  external costs, owner/environment, dashboards, VPA recommendations and estimate/budget/expiry
  gates before plan/apply. Cloud destroy remains manual.
- Three TX proved HPA/PDB/drain and positive measured namespace cost. Three DX proved Gateway
  SLO, HPA up/down, before/after requests, quota denial and real PostgreSQL pool saturation/recovery.
  Full uses three nodes; small retains one node/7 GiB and passed separately.
- CI found dependency-install order in label tests, asynchronous allocation reads and a
  ConfigMap-mounted client's symlink path. Regression tests reject the old guard that exited
  before running load.
- No cloud ran. Smaller requests/simulated prices do not prove billed savings or managed scaling/Spot.

Merged PRs: [tx01v2#18](https://github.com/maringelix/tx01v2/pull/18), [dx01v2#20](https://github.com/maringelix/dx01v2/pull/20), [tx02v2#18](https://github.com/maringelix/tx02v2/pull/18), [dx02v2#15](https://github.com/maringelix/dx02v2/pull/15), [tx03v2#17](https://github.com/maringelix/tx03v2/pull/17), [dx03v2#17](https://github.com/maringelix/dx03v2/pull/17).

## 2026-10-17: R11 acceptance and full-scope curriculum

- All 21 R7–R10 implementation PRs merged with applicable green checks; this hub closure completed
  the 22 planned DEC-13 PRs.
- Added 17 lessons, requirement/cloud/implementation/test/limit/round/PR matrix, future cloud
  validation path and reconciled READMEs/roadmap.
- DELIVERIES.json is checked by fixtures and merged main commits. Family checks cover FinOps
  files/pins, identical load clients and standalone CI without maintainer cloud credentials.
  A second real GitHub account was not used; execution evidence comes from clean Actions runners.
- Cloud validation and maintenance retain separate states. Closure claims neither 24/7 service
  operation nor approval of v2 infrastructure in real accounts.

## 2026-10-18: cloud-readiness audit corrections

A separate read-only audit identified cloud configuration/IAM issues after the 22 construction PRs.
Four correction PRs merged with green applicable CI:

- [tx01v2#20](https://github.com/maringelix/tx01v2/pull/20): EKS Auth/boundary/service-linked-role
  permissions, S3 version/read and ECR lookup permissions, named Kubernetes reads and Kyverno mode.
- [tx02v2#19](https://github.com/maringelix/tx02v2/pull/19): regional ACME renderer names,
  full-profile Collector identity preservation and Kyverno mode.
- [tx03v2#18](https://github.com/maringelix/tx03v2/pull/18): exact two-bucket Velero IAM, compatible
  cloud admission/mesh constraints, safe constraint migration and bounded OpenCost sample polling.
- [dx03v2#18](https://github.com/maringelix/dx03v2/pull/18): pin to merged corrected GCP platform.

The [hub family run](https://github.com/maringelix/tx00v2/actions/runs/39090472838) passed against
those mains. These fixes are additional work, outside the original 22 count. They do not establish
real cloud validation; no cloud resources were created during the audit/correction round.

## 2026-10-18: English documentation and central onboarding (DEC-14)

- Adopted English for public documentation, document filenames, contributor/agent guidance,
  examples and the shared application interface. Each repository has one canonical README.
- Translated and organized the roadmap, curriculum, acceptance, history, contracts, runbooks,
  maintenance and historical lessons. Preserved scope IDs, contract versions, delivery ledger,
  historical lessons and merged evidence.
- Added the [central getting started guide](GETTING_STARTED.md): fork protections, credential-free
  CI/local learning, account prerequisites, human bootstrap, exact per-repository variables and
  secrets, reviewed costs, workflow order, approved publication/promotion, validation, DR and
  cleanup in both regions.
- Updated harness paths/language assertions and family checks; all three DX pins reference their
  actual merged TX commits. All six cloud-repository PRs passed their complete applicable CI.
- This is an additional documentation/onboarding round, outside the original 22 construction PRs.
  No real cloud resources were created; v2 remains `not run in the cloud (v2)`.

Merged PRs: [tx01v2#21](https://github.com/maringelix/tx01v2/pull/21), [dx01v2#21](https://github.com/maringelix/dx01v2/pull/21), [tx02v2#20](https://github.com/maringelix/tx02v2/pull/20), [dx02v2#16](https://github.com/maringelix/dx02v2/pull/16), [tx03v2#19](https://github.com/maringelix/tx03v2/pull/19), [dx03v2#19](https://github.com/maringelix/dx03v2/pull/19).
