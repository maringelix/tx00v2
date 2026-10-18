# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Conventional Commits](https://www.conventionalcommits.org/).

## [Unreleased]

### Changed

- Standardized public documentation and filenames in English (DEC-14), consolidated each repo's
  README, translated the roadmap/curriculum/acceptance/history and coordinated all six lab ports.
  Roadmap statuses/fields and family checks now use the English format without changing IDs,
  delivery evidence, contract semantics or cloud validation labels.
- Closed DEC-13 construction in 22 PRs (21 merged implementation PRs plus this hub
  closure): DevSecOps/releases, integrated cloud platform, data/volume recovery and
  independent A/B failover/failback, capacity and FinOps. All implementation PRs have
  green applicable CI. Cloud homologation remains unexecuted; the original scope audit
  is preserved as a dated historical snapshot.
- Reopened the full three-cloud learning scope after the 2026-10-16 audit (DEC-13). R7–R11 plan
  22 construction PRs for DevSecOps/releases, integrated cloud platform, HA/backup/DR and
  FinOps/scaling, plus final acceptance. Earlier milestones retain their evidence; installing
  charts and passing local CI do not imply complete cloud integration or cloud homologation.
- Added the requirement-by-requirement scope audit and clarified the family status in both READMEs.

### Added

- [Central getting started guide](docs/GETTING_STARTED.md): choosing profiles, forks, cloud signup,
  bootstrap, exact per-repository variables/secrets, reviewed cost inputs, plan/apply/platform,
  signed publication/promotion, validation, recovery and both-region cleanup.
- A 17-lesson curriculum, requirement-by-cloud acceptance matrix and machine-readable
  delivery ledger. New harness fixtures reject incomplete/wrong-pair ledgers;
  family checks retain secret-free standalone CI, capacity proofs, current FinOps
  files and byte-identical app load clients.
- The family hub of the v2 lab (2026-10-14): README in English and Brazilian Portuguese with the
  family table and the references of the lab.
- Original `ROADMAP.md` (initially Brazilian Portuguese, now English): complete lab scope, the
  execution rules, every pending item (rounds R2 to R6 and the sustainment calendar) with status,
  repositories, origin, dependencies, cost, deliverables and acceptance, the v1 → v2 map and the
  decisions, registered and pending.
- Harness (`scripts/harness.sh`) with two stages:
  - `static` (CI job `static`, the required check): tool versions, repository structure,
    identifiers (account IDs, GUIDs, e-mails, public IPs), workflow policy, links (relative links
    resolve, only v2 repositories of the family), roadmap format (fields, statuses, overview table,
    dependencies, mentioned IDs), actionlint, shellcheck, gitleaks.
  - `family` (CI job `family`, informative and weekly): the standard files of the six lab
    repositories, the family tables of their READMEs, cloud and local contract versions of each
    pair, the pinned infrastructure commit of each application repository, tool and chart versions,
    image digests, byte-identical files, the same app in the three application repositories, one pin
    per action, links of the hub docs to files of the family and the merged pull requests behind every
    done item.
- Pinned tools: actionlint 1.7.12, shellcheck 0.11.0, gitleaks 8.30.1 (the versions of the lab
  repositories) and jq 1.8.2, SHA256-verified.
- `docs/GUARDRAILS.md`, `docs/HARNESS.md`, `docs/HISTORY.md` and `docs/MAINTENANCE.md` (now English);
  `FORK.md`, `AGENTS.md`, `CONTRIBUTING.md`, `SECURITY.md`.
- Repository settings as code: `.github/rulesets/main.json` (required check `static`) and
  `scripts/repo-guardrails.sh` (the settings of the family without the environment `lab`).

### Changed

- Round R4 (the cloud platform as code and the fork-to-cloud path) is complete across the six lab
  repositories: R4.1 to R4.8 are `done` with merged pull requests as evidence. No implementation
  round remains; the sustainment calendar continues. The code and CI do not claim a real cloud run.
- `family-digests` checks the effective Velero server image after merging base and cloud values,
  and requires the correct digest-pinned plugin for each provider. Provider plugins have different
  image identities; their SHA sets are no longer treated as interchangeable images.
- Round R3 (safety for whoever forks) is done in the six lab repositories: R3.10 and R3.13 to R3.18 are `done`
  with their pull requests as evidence. At the R3 close, the overview, plan and `docs/HISTORY.md`
  pointed to R4 as the remaining round; R4 is now complete. R3.16 records a change of acceptance for
  Google Cloud: the roles of the apply identity are not tied to `tx03v2-lab-*` names (a role cannot
  be tied to a resource that does not exist yet), the dedicated project and the pre-flight hold the
  rest.
- The roadmap is rewritten for the scope Bruno set on 2026-10-15 (DEC-11): the lab is ready when
  anyone who forks it can run it on Docker and in their own AWS, Azure and Google Cloud accounts;
  nothing is validated in a real cloud. Two rounds remain: R3 (safety for whoever forks: R3.10 and
  R3.13 to R3.18) and R4 (the full platform in the clouds as code, with the new R4.8, the path from the
  fork to your own cloud). DR, FinOps, HTTPS in the clouds, the extra security and quality checks, the
  real cloud runs, the fork rehearsal and the proposals left the roadmap; their texts stay in the
  history of the file, and the pending decisions DP-1 to DP-5 fell with them.
- Roadmap item R1.8 is done: `LOCAL_SIZE=small` runs the full platform with the app in 7 GB of
  Docker memory, proved in the CI of the three dx (Docker-in-Docker). The goal was 6 GB; the acceptance
  records the change and the decision. The round is in `docs/HISTORY.md`.
- Roadmap item R1.9 is done: ten green `e2e` runs in a row in each tx (11, 20 and 18), and the
  failure of the Trivy server install did not come back.
- Roadmap items R1.7, R1.10 and S.8 are done (the debts round); R1.9 records the count of green `e2e`
  runs so far and what the failed run really showed. The round is in `docs/HISTORY.md`.
- The first CI run passed (`static` 9/9, `family` 11/11 against the main branch of the six
  repositories): the status rows of the hub say `verified in CI`. `scripts/repo-guardrails.sh` was
  applied and read back with `gh api` (ruleset, secret scanning with push protection, private
  vulnerability reporting, fork run approval): `verified locally`. Roadmap item R0.6 is done.
- Roadmap item R0.7: after a read-only audit of what could break the machine or the cloud of whoever
  forks the lab, the scripts of the six repositories act only on what the lab created. The rest of
  the audit became the pending items R3.13 to R3.18. New family rule SEC-05 in `docs/GUARDRAILS.md`;
  the round is in `docs/HISTORY.md`.
