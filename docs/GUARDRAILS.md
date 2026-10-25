# v2 family guardrails

Rules for the cloud family (the six cloud labs and this hub), with their enforcement points.
Each lab has its own `docs/GUARDRAILS.md` for provider-specific IAM, networking and contract rules.
For shared rules, “Enforced by” identifies the checks on each side.

The complete learning path also includes independent tracks, currently `tx04v2`. Those tracks
follow their own repository instructions and runtime checks. The hub checks their catalog entries,
documentation links and cited merge evidence; the cloud-pair parity rules below do not apply to
them. Privacy, truthful evidence and explicit authorization for paid/cloud operations remain
requirements for the whole learning path.

Types: `blocking` (a required check fails), `warning` (an informative check fails, such as this
hub's `family` job), and `process` (review and maintenance without an automatic check).

## Rules

| ID | Rule | Reason | Enforced by | Type |
|---|---|---|---|---|
| SEC-01 | No secrets or real identifiers: account, subscription, tenant/project IDs, GUIDs, hostnames, public IPs or email addresses; placeholders only | public repositories that other people copy | `gitleaks` and `policy-identifiers` in every repository | blocking |
| SEC-02 | Cloud authentication uses OIDC or Workload Identity Federation with exact subjects; no static keys | a leaked static key does not expire by itself | TX bootstrap tests; `policy-workflows` | blocking |
| SEC-03 | `ci.yml` never requests `id-token: write`; cloud OIDC belongs in cloud workflows; mutating jobs use protected `lab` | PR CI must not access cloud resources; read-only plan has its own restricted identity | `policy-workflows` in all seven | blocking |
| SEC-04 | The hub has no cloud credentials or cloud workflow; `family` only reads public repositories | keep the hub's attack surface small | hub `policy-workflows` | blocking |
| SEC-05 | Scripts/tests act only on lab resources: no target from generic environment overrides; cloud scripts check cluster tags/labels and use temporary kubeconfigs; `platform/local` and `deploy-local.sh` require `kind-tx0Nv2-local`; integration tests require a `*_test` database | fork owners run beside unrelated work on their own machines/accounts | TX `policy-scripts`; DX `requireTestDatabase` and `test:api`; `require_lab_context` | blocking |
| SUP-01 | Pin tools by version + SHA256, actions by 40-character SHA + `# vX.Y.Z`, images by digest, charts by version + SHA256, providers with four-platform lockfiles, npm with exact versions + lockfile | reproducible builds and inspectable supply chain | repository checks; hub `family-actions`, `family-digests`, `family-versions` | blocking |
| SUP-02 | Shared versions match: tools within each role and across roles except documented exceptions; charts across TX; one digest per image and one pin per action; effective Velero server matches across TX with the correct digest-pinned provider plugin | unexplained differences are drift | `family-versions`, `family-digests`, `family-actions` | warning |
| SUP-03 | Byte-identical files: `scripts/repo-guardrails.sh` in six; `LICENSE`, `CLAUDE.md`, `CODEOWNERS` in seven; `.editorconfig`, `.gitattributes`, `.pre-commit-config.yaml`, ruleset within each role; TX `scripts/install-tools.sh`; DX `scripts/update-tool-checksums.sh`, `.nvmrc`, capacity fixtures and app migrations | fixes reach all equivalent repositories | `family-identical` | warning |
| SUP-04 | Weekly CI, grouped monthly Dependabot, dated support calendar, scanner exceptions with `statement` and `expired_at` within about seven months | idle labs still age | scheduled `ci.yml`, each repository's `trivyignore-policy`, ROADMAP section S | blocking |
| CI-01 | CI is the harness: jobs call `make <target>` | local checks and CI use the same implementation | review; each `ci.yml` | process |
| CI-02 | CI sets `HARNESS_STRICT=1`: every SKIP becomes FAIL | no silent omissions | all seven harnesses and `ci.yml` files | blocking |
| CI-03 | Never weaken gates with `continue-on-error`, `\|\| true`, `\|\| echo`, `--no-verify`, disabled checks or reduced coverage | weak gates create false confidence | all seven `policy-workflows`; review | blocking |
| CI-04 | Required ruleset checks: TX `static`, `test`, `e2e`; DX `static`, `test`, `images`, `e2e`, `e2e-platform`; hub `static` | local lab validation is a merge gate | rulesets, `scripts/repo-guardrails.sh`, hub `policy-workflows` | blocking |
| CI-05 | Jobs use `ubuntu-24.04`, `timeout-minutes`, `concurrency`, top-level read-only contents permission and `persist-credentials: false` | predictable runners, bounded jobs and credentials | all seven `policy-workflows` | blocking |
| CI-06 | Standalone lab CI needs no maintainer secrets or cloud authentication; full/small/continuity and HA/FinOps exercises remain present | forks reproduce portable behavior on clean runners | `family-fork` | warning |
| MUD-01 | Build a capability in the AWS reference pair and port it in the same round, one cohesive PR per repository | keep pairs aligned | review; ROADMAP section 3 | process |
| MUD-02 | Merge TX before DX; DX pins the merged TX commit in `deploy/local/tx0Nv2.ref`, with no later local platform changes | DX tests the current platform | `family-ref` | warning |
| MUD-03 | Contract changes need coordinated PRs and a version bump; `docs/CONTRACT.md` has the same title on both sides; local published/required versions agree | missing keys must not break the app | repository contract checks; hub `family-contract` | blocking |
| MUD-04 | Port changes to `api/` or `web/` to all three DX repositories in the same round | fair comparison between providers | `family-app` compares dependencies/code after name/comment normalization | warning |
| DOC-01 | Claims use evidence labels: `verified in CI`, `verified locally`, `not run in the cloud (v2)`, `planned` | readers can distinguish proof from intent | repository `repo-structure`; review | blocking |
| DOC-02 | No self-praise or emojis; README at most 250 lines | factual documentation | `repo-structure` | blocking |
| DOC-03 | Never link private, archived v1 repositories | avoid broken links and stale dependencies | hub `docs-links`; `family-table` | blocking |
| DOC-04 | Each English README includes the family table linking the other repositories | every entry point leads to the family | `family-table` | warning |
| DOC-05 | ROADMAP has required fields, valid statuses, registered hub/cloud/track repositories, existing dependencies and an overview matching its items | a checkable delivery plan | `roadmap` | blocking |
| DOC-06 | `done` items have merged PRs in `Evidence`; `docs/HISTORY.md` cites merged PRs only | status stays within its proof | `family-evidence` | warning |
| DOC-07 | Each lab has the v2 standard files: English README, AGENTS, FORK, guardrails, harness, maintenance, contract, runbook, architecture, publishing and local lab docs | consistent structure across six labs | `family-structure` | warning |
| DOC-08 | Hub links to cloud and registered track paths (`blob/main/...`) exist | working navigation | `family-links` | warning |
| DOC-09 | DEC-13 ledger has three R7 app PRs, six per R8/R9/R10 and one hub closure; curriculum and acceptance matrix exist | checkable coverage of the 22 deliveries | `delivery`, `delivery-fixtures`, `family-evidence` | blocking/warning |
| DOC-10 | Public prose, templates, agent instructions and document filenames use English; central onboarding follows actual workflows | one maintained learning path | review; `repo-structure`, `docs-links`, `family-structure` | process/blocking |
| DOC-11 | Independent tracks remain outside cloud-pair parity and do not require another fork; unknown/v1 repositories and missing track paths remain rejected | extend the learning path without inventing a fourth cloud pair or weakening existing checks | `learning-track-fixtures`, `docs-links`, `family-links`; separate `FAMILY_TRACKS` catalog | blocking/warning |
| CUSTO-01 | Cloud actions need explicit human authorization for that action; each round ends the same day with destroy, leftovers and `cloud_run_report` | the operator pays | manual cloud workflows; protected `lab` on mutations; repository AGENTS | process |
| CUSTO-02 | Bootstrap budgets/alerts enabled by default; cheapest working defaults; costs name amount and source | avoid unexpected bills | TX bootstrap tests; ROADMAP `Cost` | blocking |
| CUSTO-03 | Reviewed regional prices, duration and expiry <=24 hours before plan/apply; cloud teardown remains manual | estimates/budgets are neither billing caps nor permission to destroy an account | TX FinOps gates/docs | blocking/process |
| AGT-01 | Follow the repository AGENTS and pause before cloud actions, contract changes, wider IAM/network/RBAC, new ignores or history rewrites unless already authorized | agent mistakes propagate quickly | all seven AGENTS | process |
| AGT-02 | One heavy local lab run at a time (8 GB Docker for basic full; HA/FinOps recommends 12 GiB); heavy validation for Bruno's workspace stays in Actions | protect host resources | lab AGENTS | process |

## Exceptions

Every exception has a reason and an ending roadmap item:

- Tool differences between roles: `FAMILY_VERSION_EXCEPTIONS` in `scripts/harness.sh` currently
  records only `KUBECTL_VERSION`: TX 1.37, DX 1.36 until S.2. Every run prints it.
- Lab scanner exceptions live in `.trivyignore.yaml` with `statement` and `expired_at`.
- Add an exception through a PR explaining why and naming its removal item; never to hide a failure.

## Limits

- `family` is informative: it reports drift but cannot prevent a lab repository from merging
  inconsistent work. It runs on hub PRs, every main push and Mondays.
- It reads each repository's main (or local checkouts with `FAMILY_SOURCE`); open lab PRs appear
  after merge.
- Independent track links/evidence use a present `FAMILY_SOURCE/<track>` checkout or the public
  upstream. The `FAMILY_OWNER` fork selection and mandatory source checkouts still concern only
  the six cloud labs; cloud-only fork owners do not need to fork a track.
- Registering a track does not certify its optional modules, real hardware or cloud execution.
  Its own workflow/runbooks define the scope of runtime evidence.
- App parity compares dependencies and `api/src`/`web/src` after stripping repository names,
  full-line comments and blank lines. Tests and smoke (`e2e/`) differ because provider edges differ.
- The hub proves no real cloud behavior. Nothing of v2 has run in a cloud.

## Verification

```bash
make tools
HARNESS_STRICT=1 make verify      # this repository's SEC, CI and DOC rules
make family                      # shared versions, parity, refs, structure, links and evidence
scripts/harness.sh list
```
