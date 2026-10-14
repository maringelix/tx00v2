# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Conventional Commits](https://www.conventionalcommits.org/).

## [Unreleased]

### Added

- The family hub of the v2 lab (2026-10-14): README in English and Brazilian Portuguese with the
  family table and the references of the lab.
- `ROADMAP.md` (pt-BR): what a complete lab in the three clouds means, where the family stands, the
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
- `docs/GUARDRAILS.md`, `docs/HARNESS.md`, `docs/HISTORICO.md` and `docs/SUSTENTACAO.md` (pt-BR);
  `FORK.md`, `AGENTS.md`, `CONTRIBUTING.md`, `SECURITY.md`.
- Repository settings as code: `.github/rulesets/main.json` (required check `static`) and
  `scripts/repo-guardrails.sh` (the settings of the family without the environment `lab`).
