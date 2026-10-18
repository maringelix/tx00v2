# Forking the family

The lab is seven repositories. Each lab repository has its own `FORK.md` with the details; this page
is the overview and the links between them. Follow the [complete getting started guide](docs/GETTING_STARTED.md)
for account creation, bootstrap, variables/secrets, pipeline order, validation and teardown.

## What you need

- A GitHub account (an organization works too).
- For the local lab: Linux or WSL 2 with Docker (8 GB of memory for the `full` profile, 7 GB
  with `LOCAL_SIZE=small`), or the
  devcontainer of each lab repository. No cloud account.
- For the cloud path: your own dedicated AWS account, Azure subscription or Google Cloud project. It
  costs money; read the `docs/COSTS.md` of the pair first.

## Order

1. Fork the pair you want (or all three). Keep the repository names: the cloud identities of each
   bootstrap trust `<owner>/tx0Nv2` and `<owner>/dx0Nv2`.
2. In every fork, enable the workflows in the Actions tab, then run
   `scripts/repo-guardrails.sh <you>/<repo>` from a clone (GitHub copies no settings to a fork).
3. In each application fork, set the repository variable `TX0NV2_REPO` to your infrastructure fork,
   so the platform e2e clones your copy. Its `deploy/local/tx0Nv2.ref` must be a commit of that fork.
4. Run the local lab from your forks: `make e2e` in the infrastructure repository, then
   `make e2e-platform` in the application repository.
5. Optionally fork this hub and run `scripts/repo-guardrails.sh <you>/tx00v2`. Its job `family`
   checks the six repositories of the owner of the fork (or of the repository variable
   `FAMILY_OWNER`); a partial fork of the family fails there, so set `FAMILY_OWNER` to `maringelix`
   if you forked only the hub.

## What GitHub does not copy

Rulesets, environments, secret scanning, private vulnerability reporting, variables and secrets.
Actions and scheduled workflows stay disabled until you enable them, and Issues start off.
`scripts/repo-guardrails.sh` sets everything except variables, secrets and the cloud side.

## Links stay upstream

The docs of the family link `github.com/maringelix/...`. A fork keeps those links; the `family-table`
and `family-links` checks look for them as they are.

## Per repository

| Repository | FORK.md |
|---|---|
| tx01v2 | [tx01v2/FORK.md](https://github.com/maringelix/tx01v2/blob/main/FORK.md) |
| dx01v2 | [dx01v2/FORK.md](https://github.com/maringelix/dx01v2/blob/main/FORK.md) |
| tx02v2 | [tx02v2/FORK.md](https://github.com/maringelix/tx02v2/blob/main/FORK.md) |
| dx02v2 | [dx02v2/FORK.md](https://github.com/maringelix/dx02v2/blob/main/FORK.md) |
| tx03v2 | [tx03v2/FORK.md](https://github.com/maringelix/tx03v2/blob/main/FORK.md) |
| dx03v2 | [dx03v2/FORK.md](https://github.com/maringelix/dx03v2/blob/main/FORK.md) |

The standalone CI runs on clean Actions runners without maintainer/cloud secrets; family-fork
checks that this property and the required runtime jobs remain present. A second real GitHub account
was not used. See the [acceptance matrix](docs/ACCEPTANCE.md) and [curriculum](docs/CURRICULUM.md).

## Capacity, prices and expiration

For R10, use LOCAL_TOPOLOGY=ha LOCAL_FINOPS=1 on the default size (12 GiB recommended).
Keep small on one node/7 GiB. Cloud plans require current regional price input, budget, duration
and expiration from each TX docs/FINOPS.md. Cloud workflows remain manual and protected by lab;
an expired estimate never authorizes automatic destruction of an existing account.
