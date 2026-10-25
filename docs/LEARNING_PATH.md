# Learning path: DevOps, three clouds and AI infrastructure

`tx00v2` is the entry point and learning map. The executable labs stay in their own repositories:
the three infrastructure/application pairs and the independent
[tx04v2 AI/GPU lab](https://github.com/maringelix/tx04v2).
Use this page for study order, [CURRICULUM.md](CURRICULUM.md) for the existing A01–A17 lessons,
and [ROADMAP.md](../ROADMAP.md) for implementation work and evidence. The lesson IDs remain stable.

This path expands the earlier cloud curriculum under DEC-15. Publishing a study plan does not
complete its exercises: guided beginner packs and the new AI/GPU deliverables are pending in
R12.1–R12.5. Existing cloud construction and its limits remain in
[ACCEPTANCE.md](ACCEPTANCE.md).

## Choose an execution route

- **No cloud account or physical GPU:** learn the architecture of each provider, inspect its IaC,
  and use the documented mocks, Docker/kind and hosted CI exercises. Then study the AI/GPU track
  and its available simulated infrastructure. No purchase or paid cloud run is required to follow
  the learning sequence. Hosted services remain subject to the learner's account limits.
- **Optional cloud execution:** after the local checkpoint for one provider, use A17 and
  [GETTING_STARTED.md](GETTING_STARTED.md) to validate that provider in an authorized, bounded
  account session. Finish its cleanup before opening the next provider session.
- **Optional real hardware:** follow the future hardware exercises only with a supported,
  isolated environment and an explicit resource budget. A simulated GPU is not hardware evidence.

Cloud execution and hardware access add evidence; neither is a prerequisite for studying the
later stages. A skipped execution checkpoint must stay recorded as unexecuted.

## Progression and checkpoints

Follow the stages in order. Experienced learners can attempt a checkpoint first and study the
topics they cannot yet explain or demonstrate. A green workflow alone does not replace the
learner's explanation of the architecture, failure and recovery.

| Stage | Study and practice | Existing material and delivery state | Checkpoint artifact |
|---|---|---|---|
| 0. DevOps foundations | Linux files/processes/permissions, shell, Git/PRs/conflicts, DNS/HTTP/TLS, container images/ports/volumes, tests and basic Kubernetes objects | A01/A04 provide context but assume prior knowledge; guided foundation exercises are **pending R12.1** | Request-path diagram; reproducible commands; diagnose a broken configuration, recover it and show cleanup |
| 1. Cloud architecture | Requirements and SLOs, stateless/stateful components, networks, identity, secrets, IaC/state, managed-service tradeoffs, failure domains and cost drivers | A02–A06 and each pair's architecture docs; guided architecture pack is **pending R12.1** | Architecture diagram plus an ADR comparing alternatives, trust boundaries, state ownership, recovery and cost controls |
| 2. AWS reference implementation | Work through the app and platform once: artifact delivery, GitOps, edge, identity, observability, security, continuity and capacity | [tx01v2](https://github.com/maringelix/tx01v2) + [dx01v2](https://github.com/maringelix/dx01v2); A01–A16 | Trace a request through the app/database; demonstrate a tested rollout/recovery scenario and explain its evidence limits |
| 3. Azure comparison | Reproduce the same learning outcomes; compare network/identity/state/edge and managed Kubernetes/database choices | [tx02v2](https://github.com/maringelix/tx02v2) + [dx02v2](https://github.com/maringelix/dx02v2); reuse A01–A16 | AWS→Azure comparison sheet and matching app/recovery evidence; explain provider-specific differences |
| 4. Google Cloud comparison | Repeat the comparison, including Autopilot constraints and its supported platform paths | [tx03v2](https://github.com/maringelix/tx03v2) + [dx03v2](https://github.com/maringelix/dx03v2); reuse A01–A16 | Three-provider decision matrix: implementation, identity, operating limits, recovery, cost drivers and teardown |
| 5. Real local AI on CPU | Model/token/context concepts, reproducible model/runtime artifacts, API serving, memory and latency/throughput measurements | See [AI_GPU_TRACK.md](AI_GPU_TRACK.md); an incomplete reference exists, but a runnable guided path is **pending R12.2** | Real generated output and a bounded benchmark with runtime/model revisions, resource measurements and cleanup |
| 6. Simulated GPU infrastructure | Device resources, placement, queues/gang scheduling, mock serving, autoscaling signals, fleet simulation, telemetry and incident diagnosis | tx04v2 contains modules and exercises; guided coverage and runtime gates are **pending R12.3** | Explain allocation and a scheduling failure; run a bounded exercise, observe the failure/recovery and label synthetic signals correctly |
| 7. Real GPU and advanced infrastructure | Hardware compatibility, driver/runtime/plugin layers, VRAM, sharing/isolation, model serving and multi-GPU concepts | Hardware notes exist; validated exercises are **pending R12.4** | Compatibility inventory plus measured hardware behavior, controlled failure/recovery and a documented operating boundary |
| 8. AI infrastructure capstone | Combine architecture, delivery, serving, observability, capacity, security and recovery | Integrated exercise and benchmark/operations pack are **pending R12.5** | Reviewed architecture and reproducible evidence bundle with a request path, benchmark, rollback, incident recovery and cleanup |

The detailed AI sequence and its current boundaries are in [AI_GPU_TRACK.md](AI_GPU_TRACK.md).
The roadmap tracks the missing deliverables; this page does not mark them complete.

## How to study the three clouds

Use AWS as the reference pair, then Azure, then Google Cloud. Keep the same React/Express/
PostgreSQL application and the same acceptance question for each provider. Change the deployment
configuration and provider integration where required; do not turn the exercise into three
different applications.

Within the reference pair, follow the existing catalog:

1. **A01–A06:** forks/contracts, Terraform/network/state, Kubernetes, the app, quality/security
   gates and artifact supply chain.
2. **A07–A11:** GitOps, edge/TLS/WAF, mesh, observability and runtime policies.
3. **A12–A14:** backup/PITR, DR and controlled failure/recovery.
4. **A15–A16:** autoscaling, bottlenecks, allocation and cost reasoning.
5. **A17:** optional real-account validation, with its own authorization, budget and teardown.

For Azure and Google Cloud, reuse the same lesson IDs and evidence template. Write down what is
portable and what the provider changes. At minimum compare network topology, workload identity,
state/registry, ingress/TLS/WAF, managed database, observability, capacity and recovery.
Mocks and kind prove their tested behavior; they do not prove managed-service failover, real IAM,
cloud quotas or billed costs. Cloud paths remain `not run in the cloud (v2)` until account evidence
establishes otherwise.

## Evidence for every checkpoint

Keep a small learning record for each exercise:

1. **Intent:** objective, diagram and expected behavior; identify the concepts being tested.
2. **Reproduction:** repository revision, environment/profile and exact commands.
3. **Observation:** expected versus observed results, including any failed or unexecuted step.
4. **Diagnosis and recovery:** one bounded failure, the signal that explains it, the corrective
   action and evidence that normal behavior returned.
5. **Resources and cost:** host capacity or account budget/window, load limits and stop conditions;
   separate estimates from measured usage or invoices.
6. **Cleanup:** the documented teardown, leftover inventory and any intentionally retained state.

Use synthetic data and sanitized evidence. Run resource-heavy exercises on a disposable machine
or hosted runner, one bounded session at a time. Follow the executable repository's own harness,
prerequisites and cleanup procedure; the hub is not an infrastructure launcher.

## What the hub checks

The learning map covers eight repositories: this hub, six cloud-pair repositories and tx04v2.
The existing `make family` checks still compare **the six cloud-pair repositories**: their app
parity, versioned contracts, pinned references and shared tooling. tx04v2 has its own architecture,
toolchain and CI; its inclusion in the study path does not place it inside those parity checks.

Do not interpret the earlier cloud construction closure as completion of the new beginner,
local-inference or hardware curriculum. Their acceptance and delivery status belong to R12 in
[ROADMAP.md](../ROADMAP.md).
