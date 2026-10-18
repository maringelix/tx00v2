## What and why

<!-- One or two sentences. Link the issue or the roadmap item (ROADMAP.md, e.g. R2.1) if there is one. -->

## Definition of Done

- [ ] `HARNESS_STRICT=1 make verify` passes locally (Linux, WSL 2 or the Docker one-liner of docs/HARNESS.md)
- [ ] CI is green (`static`; `family` is informative, see docs/HARNESS.md)
- [ ] ROADMAP.md: statuses, overview table and evidence (merged PR links) match what really happened
- [ ] docs/HISTORY.md and CHANGELOG `[Unreleased]` updated when a round of the lab ended
- [ ] No claim stronger than the evidence (labels `verified in CI`, `verified locally`, `not run in the cloud (v2)`, `planned`)
- [ ] Every new action is pinned (40-character commit SHA + `# vX.Y.Z`); tools by version + SHA256
- [ ] No secrets or real identifiers (account IDs, GUIDs, IPs, e-mails) and no links to the v1 repositories

## Cloud impact

None: the hub talks to no cloud. Cost estimates in ROADMAP.md come from the `docs/COSTS.md` of the
lab repositories.

## Notes for the reviewer
