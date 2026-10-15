# tx00v2

Family hub of the v2 DevOps lab: roadmap, family guardrails and cross-repo checks for the AWS, Azure and Google Cloud pairs.

[![ci](https://github.com/maringelix/tx00v2/actions/workflows/ci.yml/badge.svg)](https://github.com/maringelix/tx00v2/actions/workflows/ci.yml)

[Português](README.pt-BR.md)

## What is this

A public, educational DevOps lab in three clouds, built as six repositories: one infrastructure and
one application repository per cloud. The three application repositories run the same app on
purpose, so the clouds can be compared fairly. Every repository is checked by a local harness that
needs no cloud account, and the whole platform of the v1 lab runs on a local kind cluster in CI.
**Nothing of v2 has run in a cloud yet**: the cloud paths are code with tests.

This repository holds no infrastructure and no app. It links the family, keeps the roadmap of what is
still missing for the lab to be ready for forks ([ROADMAP.md](ROADMAP.md), pt-BR): anyone who forks it
runs it locally on Docker and in their own clouds, which this lab never validates in a real cloud;
the rules the seven repositories follow ([docs/GUARDRAILS.md](docs/GUARDRAILS.md)) and a harness
that checks the six lab repositories against each other.

## The family

| Repository | Cloud | Role | Status |
|---|---|---|---|
| `tx00v2` (this repo) | all three | family hub: roadmap, family guardrails, cross-repo checks | see the status tables below |
| [`tx01v2`](https://github.com/maringelix/tx01v2) | AWS | infrastructure: Terraform, EKS, RDS PostgreSQL, ALB + WAF, platform layer | see its status matrix |
| [`dx01v2`](https://github.com/maringelix/dx01v2) | AWS | application: Express 5 + TypeScript API, React 19, PostgreSQL 17 | see its status matrix |
| [`tx02v2`](https://github.com/maringelix/tx02v2) | Azure | infrastructure: Terraform, AKS, PostgreSQL Flexible Server, Application Gateway for Containers | see its status matrix |
| [`dx02v2`](https://github.com/maringelix/dx02v2) | Azure | application: the same app on AKS | see its status matrix |
| [`tx03v2`](https://github.com/maringelix/tx03v2) | GCP | infrastructure: Terraform, GKE Autopilot, Cloud SQL, Cloud Armor | see its status matrix |
| [`dx03v2`](https://github.com/maringelix/dx03v2) | GCP | application: the same app on GKE Autopilot | see its status matrix |

Each pair talks through a versioned contract owned by the infrastructure repository (for AWS:
[tx01v2 docs/CONTRATO.md](https://github.com/maringelix/tx01v2/blob/main/docs/CONTRATO.md)); the
application repository pins the infrastructure commit its platform e2e uses
(`deploy/local/tx0Nv2.ref`).

## Where to start

1. Read the reference pair: [tx01v2](https://github.com/maringelix/tx01v2) and
   [dx01v2](https://github.com/maringelix/dx01v2). The Azure and Google Cloud pairs are ports of it.
2. Run the local lab, no account needed: `make e2e` in tx01v2 (Docker with 8 GB for the `full`
   profile, 7 GB with `LOCAL_SIZE=small`; [docs/LAB_LOCAL.md](https://github.com/maringelix/tx01v2/blob/main/docs/LAB_LOCAL.md)),
   then `make e2e-platform` in dx01v2.
3. Pick an item of [ROADMAP.md](ROADMAP.md); the execution rules are in its section 3.
4. Forking the lab for a team: [FORK.md](FORK.md).

## Status of the hub

| Capability | Status | Evidence |
|---|---|---|
| Repository checks: required files, identifiers, workflow policy, links, roadmap format, actionlint, shellcheck, gitleaks | `verified in CI` | `make static`; CI job `static` (required) |
| Family checks: standard files, family tables, contract versions, pinned refs, tool and chart versions, image digests, identical files, app parity, action pins, links and evidence of the hub docs | `verified in CI` | `make family` against the main branch of the six repositories; CI job `family` (also weekly) |
| Repository settings as code (ruleset requiring `static`, secret scanning, private vulnerability reporting) | `verified locally` | `scripts/repo-guardrails.sh` applied and read back with `gh api` on 2026-10-14 |
| Cloud | not applicable | the hub talks to no cloud and has no cloud credentials |

## The family at a glance (2026-10-14)

| Capability | Status | Where |
|---|---|---|
| Harness, CI (`static`, `test`, `e2e`; apps also `images`, `e2e-platform`), rulesets, Dependabot, weekly CI | `verified in CI` | the six repositories |
| The v1 platform on a local kind lab: Istio ambient, Gateway API + cert-manager, External Secrets, Prometheus, Alertmanager, Grafana, Loki, Argo CD, Gatekeeper, Trivy Operator, Velero, Chaos Mesh (34 probes per infrastructure repository) | `verified in CI` | job `e2e` of tx01v2, tx02v2, tx03v2 |
| The app on that platform through GitOps (18 probes per application repository) | `verified in CI` | job `e2e-platform` of dx01v2, dx02v2, dx03v2 |
| Round 1: OpenTelemetry traces (Collector + Tempo), Slack alerts, chaos with hypotheses, zero-downtime rollout | `verified in CI` | ROADMAP.md, items R1.1 to R1.6 |
| Cloud paths of the three clouds (bootstrap, apply, platform layer, deploy, destroy + leftovers) | `not run in the cloud (v2)` | `docs/RUNBOOK.md` of each repository |
| DR, FinOps, SonarQube, OWASP ZAP, ACME, Istio traffic management, the full platform in the clouds | `planned` | [ROADMAP.md](ROADMAP.md) |

## Harness

You need Linux or WSL 2 with bash >= 4.4, curl, tar, xz, git and make.

```bash
git clone https://github.com/maringelix/tx00v2.git && cd tx00v2
make tools                     # actionlint, shellcheck, gitleaks, jq into .tools/ (SHA256-verified)
HARNESS_STRICT=1 make verify   # the static stage (CI job static, required)
make family                    # cross-repo checks: clones the main branch of the six repositories
make help
```

| Target | What it runs | When |
|---|---|---|
| `make tools` | `scripts/install-tools.sh`: actionlint 1.7.12, shellcheck 0.11.0, gitleaks 8.30.1, jq 1.8.2 | once, and after a tool bump |
| `make static` / `make verify` | `scripts/harness.sh static` | every change (CI job `static`) |
| `make family` | `scripts/harness.sh family` (network, or `FAMILY_SOURCE=<dir with checkouts>`) | every change and weekly (CI job `family`, informative) |
| `make all` | static + family | before a roadmap update |
| `make clean` | removes `.tools/` and the scratch data | any time |

On Windows without WSL, run it in a throwaway container (see [docs/HARNESS.md](docs/HARNESS.md)).
`scripts/harness.sh list` prints every check.

## Docs

The docs of this repository are in Brazilian Portuguese.

| Doc | Content |
|---|---|
| [ROADMAP.md](ROADMAP.md) | everything still missing, item by item: status, repositories, origin, deliverables, acceptance, cost, dependencies; the v1 → v2 map and the decisions |
| [docs/GUARDRAILS.md](docs/GUARDRAILS.md) | the rules of the family and where each one is enforced |
| [docs/HARNESS.md](docs/HARNESS.md) | the checks of the hub, what they prove and what they do not |
| [docs/HISTORICO.md](docs/HISTORICO.md) | what was done, round by round, with the pull requests |
| [docs/SUSTENTACAO.md](docs/SUSTENTACAO.md) | routines of the hub and how to react when `family` turns red |
| [FORK.md](FORK.md) | forking the family |

Reference docs of the lab, in [tx01v2](https://github.com/maringelix/tx01v2):
[architecture](https://github.com/maringelix/tx01v2/blob/main/docs/ARQUITETURA.md),
[local lab](https://github.com/maringelix/tx01v2/blob/main/docs/LAB_LOCAL.md),
[runbook](https://github.com/maringelix/tx01v2/blob/main/docs/RUNBOOK.md),
[costs](https://github.com/maringelix/tx01v2/blob/main/docs/CUSTOS.md),
[sustainment](https://github.com/maringelix/tx01v2/blob/main/docs/SUSTENTACAO.md) and
[lessons learned from v1](https://github.com/maringelix/tx01v2/blob/main/docs/LICOES_APRENDIDAS.md).

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md) (also for humans). Security
issues: [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE) — Copyright (c) 2025-2026 Bruno Maringeli.
