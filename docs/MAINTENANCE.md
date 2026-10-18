# Maintaining tx00v2

## 1. Purpose and scope

Keep the hub accurate: the roadmap reflects completed work, family checks pass, and tools match
the lab repositories. Each lab repository's `docs/MAINTENANCE.md` covers its images, charts,
providers, Kubernetes and database support. The dated family calendar is in section S of
[ROADMAP.md](../ROADMAP.md).

## 2. Routines

| When | Work | If it fails |
|---|---|---|
| Every Monday, 06:00 UTC (automatic) | Scheduled CI: `static` and `family` | section 3 |
| Monthly | Dependabot PRs (actions and pre-commit) | merge the same bump into all six lab repositories in the same round (`family-actions`) |
| Each lab round | ROADMAP status/evidence, `docs/HISTORY.md` and `CHANGELOG.md` in one documentation PR | `roadmap` and `family-evidence` identify inconsistencies |
| Quarterly (next: January 2027, item S.9) | actionlint, shellcheck, gitleaks and jq with `scripts/update-tool-checksums.sh`, alongside the lab repositories' quarterly review | `family-versions` reports drift |

## 3. When family fails

`family` checks the six repositories' `main` branches. A failure usually reports drift there:

| Check | Typical cause | Fix |
|---|---|---|
| `family-ref` | a TX merged a local platform change while its DX still pins the earlier commit | a DX PR updating `deploy/local/tx0Nv2.ref` and passing `e2e-platform` |
| `family-contract` | one side changed its contract version | complete the coordinated contract PRs |
| `family-versions`, `family-digests`, `family-actions` | a bump merged in only one repository | port it; an intentional difference needs a reason and an ending roadmap item |
| `family-identical` | a common file changed in one repository | port it to the other repositories of that role |
| `family-app` | one DX changed the app without the other ports | port to the other two DX repositories |
| `family-table`, `family-structure` | a README or standard file changed | fix the lab repository |
| `family-links` | a family file was renamed | update the hub link |
| `family-evidence` | an item became `done` before merge | correct the status or finish the merge |

An exception must have a reason and a roadmap item that removes it
([GUARDRAILS.md](GUARDRAILS.md), “Exceptions”). Never add one just to turn a check green.

## 4. Procedures

### 4.1 Update a tool

```bash
scripts/update-tool-checksums.sh <tool> <version>   # upstream versions.env + checksums.txt
make tools && HARNESS_STRICT=1 make verify && make family
```

actionlint, shellcheck and gitleaks are shared with the lab repositories: update them in the same round.

### 4.2 Close a lab round

1. Confirm that every PR merged with green CI.
2. Update ROADMAP: `done`, merged PR links in `Evidence`, overview, and newly discovered work.
3. Add the round to `docs/HISTORY.md`, including PRs and CI findings.
4. Run `make static family`, open a PR, wait for green CI, then merge.

### 4.3 Reapply repository settings

```bash
scripts/repo-guardrails.sh maringelix/tx00v2
gh api repos/maringelix/tx00v2/rulesets --jq '.[].name'
```

On Windows Git Bash, do not export `MSYS_NO_PATHCONV=1`: `gh.exe` needs path conversion for
the ruleset's `--input` argument.

## 5. Recorded baseline (2026-10-14)

- Tools: actionlint 1.7.12, shellcheck 0.11.0, gitleaks 8.30.1, jq 1.8.2.
- Recorded exception: `KUBECTL_VERSION` (TX 1.37, DX 1.36), until S.2.
- Ruleset: required `static`; informative `family`.

## 6. Ownership and language

Bruno Maringeli (`@maringelix`) owns the seven repositories. AI agents follow
[AGENTS.md](../AGENTS.md) and require explicit authorization before cloud actions.
Public documentation, templates, agent instructions and new document filenames use English.
Keep the central [getting started guide](GETTING_STARTED.md) aligned with actual workflows
whenever inputs, variables, secrets, profiles or deployment order change.
