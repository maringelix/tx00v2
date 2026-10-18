# tx00v2 harness

Every check is a registered function in scripts/harness.sh. Make targets and CI jobs call that
script. It prints PASS|FAIL|SKIP <check> (<seconds>s) and a summary; any failure exits 1.

## Stages

| Stage | CI job | Required | Prerequisites |
|---|---|---|---|
| static | static | yes, ruleset | make tools dependencies/git; no network after installation |
| family | family | no, informative | network to clone six mains, or FAMILY_SOURCE |
| all | — | — | static + family |
| list | — | — | lists checks |

Family depends on six other repositories: a merge there can fail it without changes here.
It runs on PRs, main pushes and Mondays at 06:00 UTC. Failures indicate drift
([MAINTENANCE.md](MAINTENANCE.md), section 3).

## Static checks

| Check | Proves | Does not prove |
|---|---|---|
| tool-versions | PATH tools match tools/versions.env | — |
| repo-structure | required files; CLAUDE has @AGENTS.md plus one sentence; canonical English README <=250 lines, factual status labels/no self-ratings; no doc emojis; LF; indexed executable bits | prose quality or automatic language detection |
| policy-identifiers | no non-placeholder 12-digit accounts, GUIDs, emails or public IPs | differently encoded identifiers |
| policy-workflows | SHA/comment action pins, read-only global contents, concurrency/timeouts/ubuntu-24.04, no persisted checkout credentials/swallowed errors/id-token write; static required and family informative | intended workflow behavior |
| docs-links | relative Markdown paths exist; GitHub family links name only known v2 repositories; no private archived v1 links | changed external destinations; family-links covers family paths |
| roadmap | required fields, valid statuses/repos/dependencies, done items with Evidence PRs depending only on done items, matching overview, all mentioned IDs exist | whether PRs merged; family-evidence checks that |
| delivery | DEC-13 ledger has 21 unique implementation PRs plus one hub closure, correct per-round/provider coverage and acceptance material | actual merges |
| delivery-fixtures | incomplete/wrong-pair/non-app-R7 ledger mutations are rejected | implementation semantics |
| actionlint | workflow syntax/expressions and shellcheck for run blocks | — |
| shellcheck | scripts pass severity=style | — |
| gitleaks | no recognized secrets in all history, or directory before first commit | unknown secret formats |

Roadmap statuses are done, in progress, pending, blocked, proposal; required fields are Status,
Repos, Origin, Dependencies, Cost, Deliverables and Acceptance. Completed items add Evidence.
Use none for no dependencies.

## Family checks

| Check | Proves | Does not prove |
|---|---|---|
| family-structure | six labs have English standard files and role-specific docs/code: TX costs/lessons/platform/local/FinOps; DX API/Node/packages/local deploy/platform e2e/TX ref | their content |
| family-table | seven English READMEs link the other family repositories and no v1 | other README content |
| family-contract | matching cloud contract title/version/date per pair; DX local required version equals TX publication at pin/main | every key; repository contract checks cover those |
| family-fork | standalone CI has no maintainer secrets/cloud auth and retains full/small/continuity/HA/FinOps jobs | second-account settings or real cloud execution |
| family-ref | DX pin is on TX main and no later commit changed local platform/FinOps, terraform/envs/local, local scripts/helpers/leftovers; reports lag | whether DX e2e would pass with latest main |
| family-versions | common tool keys agree by role/across family except printed documented exceptions; TX platform/local/FinOps pins agree | versions outside these files |
| family-digests | one digest per image name:tag; matching shared file digest sets by role; effective Velero base+overlay server matches with exactly the correct pinned provider plugin | undigested images outside Velero values; repository gates cover those |
| family-identical | SUP-03 files are byte-identical and DX migrations match | — |
| family-app | matching dependencies/engines/workspaces and api/src/web/src after removing repo names/full-line comments/blank lines | provider-specific tests/smoke |
| family-actions | one action SHA/tag per action across seven | — |
| family-links | hub blob/tree/main family links resolve to existing paths | heading anchors |
| family-evidence | ledger, done-item Evidence and HISTORY PRs have squash subjects (#n) in repository main | that a PR satisfies its claimed scope; review covers that |

## Variables

| Variable | Effect |
|---|---|
| HARNESS_STRICT=1 | every SKIP becomes FAIL in CI |
| HARNESS_VERBOSE=1 | print passing checks' output |
| HARNESS_WORK_DIR | scratch logs/clones/cache, default $TMPDIR/tx00v2-harness; never inside source |
| HARNESS_ONLY=<regex> | matching checks only, for local debugging; never CI |
| FAMILY_OWNER | six-repository owner, default maringelix; CI uses vars.FAMILY_OWNER or repository owner |
| FAMILY_SOURCE=<dir> | existing <dir>/<repo> checkouts as-is, any branch, no cloning; coordinated-PR inspection |

Partial clones use --filter=blob:none: full commit history with blobs fetched when needed.
They live under $HARNESS_WORK_DIR/family and refresh once per run.

## Windows without WSL

A disposable light tool container avoids source-folder caches, useful under OneDrive:

```bash
docker run --rm -v "$PWD:/src:ro" ubuntu:24.04 bash -c '
  apt-get update -qq && apt-get install -y -qq git curl xz-utils make ca-certificates >/dev/null &&
  cp -r /src /work && cd /work && git config --global --add safe.directory "*" &&
  make tools && HARNESS_STRICT=1 make verify && make family'
```

Windows-created commits may lose indexed executable bits. repo-structure reports the correction:
git update-index --chmod=+x <file>.

## Adding a check

1. Implement check_<name> in scripts/harness.sh; print inspected facts, return 1 on failure.
   Use skip "<reason>" only for missing local prerequisites such as tools/network.
2. Register in the correct stage.
3. First run new family invariants against current repositories with FAMILY_SOURCE.
   An already-false invariant becomes a roadmap item before enforcement.
4. Document here and in [GUARDRAILS.md](GUARDRAILS.md); pass make static family before PR.

## Common problems

| Symptom | Cause | Action |
|---|---|---|
| SKIP family-*: github.com is not reachable | no network | restore network or use FAMILY_SOURCE |
| family-ref fails after TX merge | DX pins earlier platform | merge the DX pin update |
| family-versions/actions fail after monthly bumps | only one repo updated | coordinate remaining ports |
| not executable in git index | Windows index mode | git update-index --chmod=+x <file> |
| tool-versions fails | wrong PATH version | make tools; harness prepends .tools/bin |

## R7–R11 acceptance

delivery validates 21 implementation entries plus hub closure, rounds and repositories in
docs/DELIVERIES.json. family-evidence checks merges; family-ref includes FinOps/helpers and
family-versions includes its pins. family-fork preserves credential-free full/small/HA evidence.
See [CURRICULUM.md](CURRICULUM.md), [ACCEPTANCE.md](ACCEPTANCE.md) and
[GETTING_STARTED.md](GETTING_STARTED.md).
