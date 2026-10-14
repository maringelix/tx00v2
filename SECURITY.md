# Security policy

## Reporting a vulnerability

Report privately through GitHub: **Security > Report a vulnerability** on this repository (private
vulnerability reporting is enabled by `scripts/repo-guardrails.sh` on a public repository). For a
problem in one lab repository, report it in that repository. Do not open a public issue. Never
include credentials, account IDs or IP addresses; use placeholders.

This is a personal educational project: reports are handled on a best-effort basis, with no response
time guarantee and no bug bounty.

## Supported versions

Only the latest commit on `main`. There are no releases.

## What this repository does to stay safe

- It has no cloud credentials and no cloud workflow: the CI has `permissions: contents: read` and the
  `policy-workflows` check refuses `id-token: write`.
- The harness (`make verify`, also the CI) runs gitleaks over the full history, a policy check against
  real identifiers (12-digit account IDs, GUIDs, e-mails, public IPs), actionlint and shellcheck.
- Every action is pinned by commit SHA and every tool by version and SHA256.
- The family stage only reads: it clones public repositories over HTTPS and never pushes.

## Known limits

The family checks report drift between the lab repositories; they cannot stop a lab repository from
merging something inconsistent. The security of the lab itself (IAM, network, images) is described
and enforced in each lab repository (`SECURITY.md` and `docs/GUARDRAILS.md` there). Nothing of v2 has
run in a cloud.
