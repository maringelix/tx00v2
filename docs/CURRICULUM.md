# Cloud lesson catalog: A01–A17

For the complete student sequence, start with [LEARNING_PATH.md](LEARNING_PATH.md): foundations,
architecture, AWS, Azure, Google Cloud, then [local AI and GPU infrastructure](AI_GPU_TRACK.md).
This file preserves the existing cloud lesson IDs and detailed exercises. It is a technical
catalog, not a beginner prerequisite course or proof that the later AI/GPU lessons are delivered.
Work through the reference AWS pair first, then repeat the outcomes on Azure and Google Cloud,
recording architecture differences. Real cloud validation in A17 remains optional and separate.

The same React + Node.js + PostgreSQL app is delivered by independent
[AWS](https://github.com/maringelix/tx01v2), [Azure](https://github.com/maringelix/tx02v2) and
[Google Cloud](https://github.com/maringelix/tx03v2) pairs.
Use [acceptance](ACCEPTANCE.md) to distinguish construction, CI evidence and cloud validation.
Start with the [central guide](GETTING_STARTED.md) for account/configuration/pipeline order.

## Preparation and tracks

Prerequisites: Git, Bash >=4.4, Linux/WSL2 or devcontainer; Docker and the pinned .nvmrc Node
version for apps. make tools installs version/checksum-pinned tools. Learning the app and local
platform requires no cloud account.

| Track | Order | Environment/cost |
|---|---|---|
| Foundations | A01–A06 | light checks/public CI; no cloud account |
| Platform/operations | A07–A14 | basic kind full 8 GiB, small 7 GiB; heavy runs in Actions |
| Capacity/cost | A15–A16 | three-node kind HA, 12 GiB recommended; incompatible with small |
| Future cloud validation | A17 | fork owner's dedicated account/project, domain and budget |

Take one lesson at a time. Record Git revision, commands, result, observed failure, recovery
and cleanup. Fix failed gates; unavailable tools/services cannot become approval.
Preserve job time limits.

### A01 — Forks, contracts and isolation

- Prerequisites: GitHub account and [FORK.md](../FORK.md).
- Architecture/objective: TX publishes a versioned identity/address contract; DX consumes it and
  pins the TX revision used by kind.
- Run: make static in both; make family in the hub after configuring the owner.
- Failure: malformed parameter or revision absent from the fork.
- Success: invalid inputs are rejected; fresh configuration passes without maintainer credentials.
  Diagnose contract-app, family-contract and family-ref.
- Recover: align both contracts/pin without copying upstream accounts/secrets.
- Cost/cleanup: light checks; remove only run scratch, preserve forks.

### A02 — Terraform, networking and state

- Prerequisites: A01 and TX docs/ARCHITECTURE.md/RUNBOOK.md.
- Architecture/objective: modules/providers, versioned remote state, private networks/subnets,
  DNS, routing/NAT and private database; understand plans, drift and dependencies.
- Run: TX make static/test with mocked providers, no account required.
- Failure: overlapping/public CIDR, exposed database, invalid retention or state recovery in the
  primary region. Success: negative tests reject configuration.
- Diagnose/recover: validations, provider schema, IAM and plan; fix inputs, preserve locks/pins,
  never edit applied migrations or destroy state by trial and error.
- Cost/cleanup: cloud networking/state/NAT costs require a cloud run; follow TX destroy/inventory.
  Retained buckets/keys need an explicit operator decision.

### A03 — EKS, AKS and GKE Autopilot

- Prerequisites: A02; pods, Service, Deployment and probes.
- Architecture: EKS Pod Identity/Cluster Autoscaler; AKS Workload Identity/managed autoscaler;
  GKE Autopilot WIF/managed capacity.
- Run: TX make e2e in Actions; inspect lab-system/lab-contract.
- Failure: missing readiness/resources or unavailable node.
- Success: state/events explain Pending/NotReady and probes demonstrate recovery; kind does not
  become evidence of EKS/AKS/GKE managed behavior.
- Diagnose/recover: events, rollout, scheduler, requests and controller identity.
- Cost/cleanup: kind consumes the runner; managed services wait until A17. Use local-down with the
  creating state, then leftovers-local.

### A04 — Full-stack app and PostgreSQL

- Prerequisites: A01/A03; DX docs/API.md/MIGRATIONS.md.
- Architecture: nginx-served React, Express/TypeScript, PostgreSQL pool and migrations.
- Run: DX make test/e2e; disposable PostgreSQL for integration tests.
- Failure: invalid input, missing token, unavailable database or incompatible migration.
- Success: correct validation/HTTP, enforced coverage, unexposed database and reconnect.
- Diagnose/recover: token-free structured logs, pool metrics, readiness and migration checksums;
  prepare expand/contract and restore before destructive schema changes.
- Cost/cleanup: disposable Compose/kind; never point table-dropping tests at a real database.

### A05 — DevSecOps and quality gates

- Prerequisites: A04; docs/CI_SECURITY.md.
- Architecture: real disposable SonarQube Community Build/gate, CodeQL/SAST, Trivy, gitleaks,
  coverage and OWASP ZAP; promotion depends on results.
- Run: static/test/images jobs; make dast for isolated ZAP in Actions.
- Failure: uncovered-code, SAST, fictitious-secret or failing-DAST fixtures.
- Success: negative cases block delivery; corrected versions pass. Community analysis runs the
  isolated revision without requiring commercial multibranch service.
- Diagnose/recover: scanner/gate reports; fix code/inputs or document a justified expiring exception.
  No bypass or coverage reduction.
- Cost/cleanup: transient Sonar/PostgreSQL/ZAP containers; teardown even on failure.

### A06 — Images, SBOM and supply chain

- Prerequisites: A05; DX CI_SECURITY/RUNBOOK.
- Architecture: digest images, SBOM, provenance and keyless signatures; cloud registries receive
  approved artifacts without deployment rebuilds.
- Run: images job, publish-images workflow and DX release-bundle verification.
- Failure: different SHA, changed checksum, absent signature or unexpected identity/issuer.
- Success: publication/promotion rejects altered artifacts; only green revisions advance.
- Diagnose/recover: run metadata, attestations and OIDC identity; republish through approved flow.
- Cost/cleanup: fork artifact/registry retention; no static cloud keys or public private bundles.

### A07 — GitOps, declarative deployment and rollback

- Prerequisites: A06 and TX full platform.
- Architecture: Argo CD, GitOps repo, sync/self-heal, readiness, PDB and RollingUpdate.
- Run: DX make e2e-platform with different-content revisions and induced rollback.
- Failure: never-ready image or rejected revision/migration.
- Success: continuous requests are measured during rollout; previous content returns after failure.
- Diagnose/recover: Application/events/revision/image IDs; revert to a known artifact.
  App rollback and data recovery are separate operations.
- Cost/cleanup: full profile; stop reconciliation before deleting Gateway/Ingress so no LB reappears.

### A08 — Edge, DNS, TLS and WAF

- Prerequisites: A03/A07; pair CONTRACT/RUNBOOK.
- Architecture: AWS ALB/ACM/Route53/WAF, Azure AGC/cert-manager/ACME/DNS/WAF,
  GCP Gateway/Certificate Manager/Cloud DNS/Cloud Armor.
- Run: cloud overlay rendering/validation and local Gateway HTTPS.
- Failure: untrusted certificate, unauthorized route/identity or wrong regional certificate.
- Success: CA/SNI/redirect/revision checks and IaC/manifest WAF scope pass. Native WAF engines
  and managed public issuance require cloud evidence, not kind.
- Diagnose/recover: Certificate/Gateway/Ingress/HTTPRoute, DNS and policies; recover regional TLS
  before pre-DNS DR smoke following the pair's runbook.
- Cost/cleanup: cloud domain/LB/WAF costs; remove controllers/external resources before networking.

### A09 — Mesh and advanced traffic

- Prerequisites: A07; Istio, mTLS, Gateway API and workload identity.
- Architecture: ambient on kind/EKS/AKS; supported managed mesh/sidecars on GCP.
- Run: e2e-platform canary/retry/outlier-isolation probes.
- Failure: intruder, failing backend and bad canary.
- Success: identity denied, percentages/retries observed and healthy backend continues serving.
- Diagnose/recover: waypoint/sidecar, routes, identities/traces; revert policy/revision.
- Cost/cleanup: include mesh requests in full; remove waypoints/routes during pair teardown.

### A10 — Metrics, logs, traces and Slack

- Prerequisites: A07/A09; Prometheus/Grafana/Alertmanager, Loki/Alloy, Tempo and OTel.
- Architecture: HTTP→API→PostgreSQL trace/log/exemplar correlation; configurable Slack webhook.
  Cloud exporters target X-Ray, Application Insights and Cloud Trace.
- Run: TX/DX observability/tracing/alert probes in Actions.
- Failure: deliberate alert, slow dependency or unavailable target.
- Success: metric, correlated log/trace and Slack-format payload visible in the local emulator.
- Diagnose/recover: targets/rules, pipeline/identity and retention; remove induced failure and
  confirm recovery. Delivery tests do not establish 24/7 operations.
- Cost/cleanup: budget PVC/retention and managed ingestion; delete disks or document retention.

### A11 — Policies and runtime security

- Prerequisites: A05/A07; GUARDRAILS/CI_SECURITY.
- Architecture: restricted PSA, Gatekeeper/OPA, NetworkPolicy, Kyverno, Trivy Operator;
  workload IAM/RBAC, private database and federated secrets.
- Run: gator/contract tests and full admission/scanning probes.
- Failure: unapproved image, missing probes/resources/labels, intruder identity or unsafe network rule.
- Success: expected admission/traffic denial; valid workloads and scanner reports pass.
- Diagnose/recover: constraints/events/policies/identities; fix manifests without broad permits
  or disabling admission webhooks.
- Cost/cleanup: full controllers; do not remove policies to hide failures.

### A12 — HA, physical backup and PITR

- Prerequisites: A04/A10; pair CONTINUITY.
- Architecture: opt-in RDS multi-AZ, Flexible Server HA and regional Cloud SQL; configurable
  retention/PITR/deletion protection.
- Run: TX make e2e and DX make continuity in CI.
- Failure: corrupt backup, write after recovery point and database loss.
- Success: pg_verifybackup rejects corruption; basebackup/WAL restores the selected point,
  retaining the valid write and excluding the later one; API reconnects.
- Diagnose/recover: backup catalog/age, WAL/restore point and secret-free logs.
- Cost/cleanup: HA/retention/replication cost extra; follow TX defaults/teardown.

### A13 — Velero and cross-region DR

- Prerequisites: A12; fencing, RPO/RTO, independent keys/backups.
- Architecture: secondary-region runtime/network/database/registry/secrets/config/state;
  restricted recovery reads and escrow key where required.
- Run: TX Velero byte/PVC probe; DX independent A/B drill.
- Failure: delete original bytes/PVC, lose A, attempt promotion while A is alive.
- Success: new claim restores checksum; unfenced promotion fails; B recovers/writes and failback
  to a fresh A preserves B's write with measured RPO/RTO.
- Diagnose/recover: replicas/lag, Backup/Restore/PVB/PVR, regional revision and pre-DNS TLS smoke;
  use provider-specific procedures.
- Cost/cleanup: opt-in DR never automatically authorizes promotion. Inventory both regions,
  disks, versions, registries, keys and retained state.

### A14 — Chaos Engineering

- Prerequisites: A10–A13; hypothesis, SLO and bounded window.
- Architecture: namespace/label-scoped Chaos Mesh observed through metrics/traces.
- Run: pod-kill, network-latency and CPU/memory stress probes.
- Failure: remove a replica or delay PostgreSQL.
- Success: measured hypothesis, observed requests/latency/restarts and recovery after removal.
- Diagnose/recover: AllInjected, events/traces/readiness; abort at the deadline.
- Cost/cleanup: experiment-owned objects only; privileged agent stays in its dedicated namespace.

### A15 — Autoscaling, Spot and bottlenecks

- Prerequisites: A14 and [TX FINOPS](https://github.com/maringelix/tx01v2/blob/main/docs/FINOPS.md).
- Architecture: HPA scales pods; CA/AKS/Autopilot govern capacity. Spot is disposable; retain
  critical on-demand baseline and document explicit cloud fallback.
- Run: TX LOCAL_TOPOLOGY=ha LOCAL_FINOPS=1 make e2e and matching DX make e2e-platform.
- Failure: CPU/load, worker drain, quota excess and saturated PostgreSQL pool.
- Success: real HPA up/down, PDB protects last pod, rescheduling/SLO pass; saturation is observable
  and recovers. Local tests do not prove managed-node scaling.
- Diagnose/recover: requests/metrics-server, autoscaler, taints/affinity/PDB, pool/locks;
  stop load, uncordon and restore GitOps.
- Cost/cleanup: load deadlines and pod/node maxima; kind HA in CI, cloud Spot only in A17.

### A16 — OpenCost, showback, VPA and estimates

- Prerequisites: A15; both FINOPS runbooks.
- Architecture: reviewed regional prices, owner/environment, idle/shared and external services;
  VPA Off recommends without competing with HPA.
- Run: FinOps probes and capacity/rightsizing report; cost gate for cloud plans.
- Failure: stale/wrong-region/unpriced rates, exceeded budget or expired deadline.
- Success: expensive scenario rejected, positive measured allocation, candidate requests
  maintain SLO and report aggregate replicas/CPU before/after.
- Diagnose/recover: targets/window, source/currency/date/units and external categories;
  update prices or reduce scope. Smaller requests do not imply billed savings.
- Cost/cleanup: estimates/alerts are not financial caps; destroy at session expiry and record
  retained resources/remaining costs.

### A17 — Real cloud validation and fork operation

- Prerequisites: all local lessons and [cloud checklist](ACCEPTANCE.md#cloud-validation).
- Objective: verify managed differences that mocks/kind cannot show.
- Run: bootstrap/plan/apply/platform/deploy/smoke/recovery from the pair's RUNBOOK and
  [central guide](GETTING_STARTED.md), with authorization, dedicated account, cost limits,
  domain and time window.
- Failure/success: record public TLS, identity, native HA/PITR/DR, scaling, Spot interruption
  and costs from account evidence; none is approved by analogy.
- Diagnose/recover: sanitized cloud_run_report, rehearsed rollback/restoration.
- Cleanup: both regions, leftovers and retained inventory. Future cloud execution is not needed
  to run/study the local construction.
