# AGENTS.md

Instructions for AI coding agents and humans working in `tx00v2`. `CLAUDE.md` points here; this file
is the source of truth. The full rule list of the family (pt-BR) is
[docs/GUARDRAILS.md](docs/GUARDRAILS.md).

## 1. Mission and context

- `tx00v2` is the hub of the v2 family of a public, educational DevOps lab: `tx01v2` + `dx01v2` on
  AWS, `tx02v2` + `dx02v2` on Azure, `tx03v2` + `dx03v2` on Google Cloud. It has no infrastructure,
  no app and no cloud credentials.
- It keeps three things: the roadmap of everything still missing for a complete lab in the three
  clouds ([ROADMAP.md](ROADMAP.md), pt-BR), the family guardrails and the family checks that compare
  the six lab repositories (`make family`).
- Every claim follows the labels of the family (`verified in CI`, `verified locally`,
  `not run in the cloud (v2)`, `planned`). **Nothing of v2 has run in a cloud.**
- The six lab repositories have their own `AGENTS.md`; work on them follows those files. This hub
  only links, plans and checks.

## 2. Non-negotiable rules

1. Never commit secrets or real identifiers (account, subscription, tenant and project IDs, GUIDs,
   hostnames, public IPs, e-mails). The `policy-identifiers` check enforces placeholders.
2. Never run cloud-mutating actions from here or because of something written here. A roadmap item
   that needs a cloud is executed in the lab repository, only when a human explicitly asks for that
   action in the current task.
3. Never weaken a gate: no `continue-on-error`, no `|| true` on checks, no `--no-verify`, no skipped
   check, no exception without a reason and a roadmap item that ends it (`FAMILY_VERSION_EXCEPTIONS`).
4. Never mark a roadmap item `feito` without merged pull requests in `Evidência`; never make a status
   stronger than the evidence (the `family-evidence` check verifies the merges).
5. Never link the v1 repositories (private and archived) and never copy their secrets or identifiers.
6. Pin every action (40-character SHA + `# vX.Y.Z`) and tool (version + SHA256); the versions shared
   with the lab repositories stay equal to theirs.
7. Once the ruleset is on, never push to `main`: pull requests only.

## 3. Repo map

```text
ROADMAP.md              the roadmap (pt-BR): items with status, repos, origin, deliverables, acceptance, cost
docs/                   pt-BR docs: guardrails of the family, harness, history, sustainment
FORK.md                 forking the family
.github/workflows/      ci.yml: jobs static (required) and family (informative, weekly)
.github/rulesets/       main.json: branch ruleset applied by scripts/repo-guardrails.sh
.github/ISSUE_TEMPLATE/ bug report and roadmap item forms
scripts/harness.sh      every check (stages static, family, all, list)
scripts/lib/            common.sh, tools.sh, family.sh (the six repositories and how they are reached)
scripts/install-tools.sh            pinned tools into .tools/ (SHA256-verified)
scripts/update-tool-checksums.sh    bump a tool: versions.env + checksums.txt from upstream checksums
scripts/repo-guardrails.sh          repository settings via gh api (no environment: the hub has no cloud)
tools/                  versions.env and checksums.txt of the harness tools
```

## 4. Setup

- Linux or WSL 2 (Ubuntu) with bash >= 4.4, curl, tar, xz, git, make: `make tools`.
- Windows without WSL: the Docker one-liner of [docs/HARNESS.md](docs/HARNESS.md). There is no
  devcontainer: the hub needs four small tools.
- `make family` needs the network (it clones the main branch of the six repositories) or
  `FAMILY_SOURCE=<dir>` with local checkouts `<dir>/<repo>`.

## 5. Harness commands

| Command | Runs | When |
|---|---|---|
| `make tools` | `scripts/install-tools.sh` (actionlint, shellcheck, gitleaks, jq) | first time, after a tool bump |
| `make static` | `scripts/harness.sh static`: tool versions, repo structure, identifiers, workflow policy, links, roadmap format, actionlint, shellcheck, gitleaks | every change |
| `HARNESS_STRICT=1 make verify` | the static stage with SKIP = FAIL (CI job `static`) | before every PR |
| `make family` | `scripts/harness.sh family`: the cross-repo checks (CI job `family`) | every change, weekly |
| `scripts/harness.sh list` | lists all checks | any time |

## 6. Definition of Done

- [ ] `HARNESS_STRICT=1 make verify` green locally; CI green (`static`; `family` green or its red
      explained in the PR).
- [ ] ROADMAP.md: statuses, overview table and evidence match the merged pull requests.
- [ ] docs/HISTORICO.md and CHANGELOG.md (`[Unreleased]`) updated when a round ended.
- [ ] No claim stronger than the evidence; no new unexplained exception.
- [ ] New actions and tools pinned; no secrets or real identifiers; no v1 links.

## 7. Playbooks

**Maintainer / sustentação.** Follow [docs/SUSTENTACAO.md](docs/SUSTENTACAO.md): a red weekly
`family` usually means a bump merged in one lab repository and not in the others; fix it there, not
here. After every round of the lab, update ROADMAP.md, docs/HISTORICO.md and CHANGELOG.md.

**Reviewer.** Check that every `feito` has merged PRs, that a new item has all fields and a real
acceptance criterion (a check or a probe, not an opinion), that costs cite the `docs/CUSTOS.md` of the
lab repositories, and that no exception was added without a reason and an end.

**Dependency updater.** Dependabot opens monthly PRs for the actions and pre-commit hooks. The
`family-actions` check wants one pin per action in the seven repositories: merge the same bump in the
six lab repositories in the same round. Tools only with `scripts/update-tool-checksums.sh`, and the
shared ones (actionlint, shellcheck, gitleaks) together with the lab repositories.

**Roadmap planner.** New items come from the "Roadmap item" issue form. Items beyond the v1 lab start
as `proposta` and need Bruno's OK (DP-4 in ROADMAP.md). IDs are never reused.

## 8. Common tasks

- Mark an item done: status `feito` in the item and in the overview table, `Evidência` with the PR
  links, an entry in docs/HISTORICO.md; then `make static family`.
- Add an item: the next free ID of its phase, every field, the overview table row; dependencies only
  on existing IDs or `DP-n` decisions.
- Add a family invariant: a `check_family_*` function in `scripts/harness.sh`, registered in
  `register_checks`, described in docs/HARNESS.md and in docs/GUARDRAILS.md; run it against the
  current repositories before merging (an invariant that is already false becomes a roadmap item
  first).
- Bump a tool: `scripts/update-tool-checksums.sh <tool> <version>`, then `make tools verify`.

## 9. When to stop and ask a human

- Anything that needs a cloud account, credentials or money.
- A family check fails because of a real drift between repositories: report it and fix it in the
  lab repositories with their own PRs; never add an exception just to get green.
- A decision of the "Decisões pendentes" table (DP-n), or a new proposal.
- Rewriting git history, force-pushing, changing repository settings or rulesets.
- Anything that would make a README, roadmap or doc claim stronger than the evidence.
