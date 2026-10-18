# Contributing

Thanks for helping. This hub plans and checks the six repositories of the lab; it claims only what
its harness and the lab repositories prove.

Forking the family to run it on your own machine and cloud accounts? Start with [FORK.md](FORK.md).

## Workflow

1. Open an issue for anything non-trivial: the bug report form, or the "Roadmap item" form for a new
   item of [ROADMAP.md](ROADMAP.md).
2. Branch from `main`; use [Conventional Commits](https://www.conventionalcommits.org/)
   (`feat:`, `fix:`, `docs:`, `chore:`, `ci:`, `refactor:`, `test:`).
3. `make tools` once, then `HARNESS_STRICT=1 make verify` and `make family` before pushing.
4. Optional fast feedback: `pre-commit install` (hooks in `.pre-commit-config.yaml`).
5. Open a PR and complete the Definition of Done in the template. Merges are squash-only.

Work on the lab itself (infrastructure, platform, app) happens in the lab repositories, each with its
own CONTRIBUTING.md; this hub only records the plan and the result.

## Rules that matter most

- No secrets or real identifiers (account IDs, GUIDs, IPs, e-mails) anywhere, including examples.
- A roadmap item is `done` only with merged pull requests in `Evidence`.
- Do not weaken checks or add an exception without a reason and the roadmap item that ends it.
- Pin new actions (full commit SHA + `# vX.Y.Z`) and tools (version + SHA256).
- Never link the v1 repositories.
- Public documentation, templates, agent instructions and new document filenames use English.
- Update [GETTING_STARTED.md](docs/GETTING_STARTED.md) when workflow inputs, variables, secrets,
  profiles or the operating sequence change.

The full rule list is in [docs/GUARDRAILS.md](docs/GUARDRAILS.md); agents and humans also follow
[AGENTS.md](AGENTS.md).
