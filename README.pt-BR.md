# tx00v2

Hub da família do lab DevOps v2: roadmap, guardrails da família e checks entre os repositórios dos pares AWS, Azure e Google Cloud.

[![ci](https://github.com/maringelix/tx00v2/actions/workflows/ci.yml/badge.svg)](https://github.com/maringelix/tx00v2/actions/workflows/ci.yml)

[English](README.md)

## O que é

Um lab de DevOps público e educacional em três nuvens, feito de seis repositórios: um de
infraestrutura e um de aplicação por nuvem. Os três repositórios de aplicação rodam o mesmo app de
propósito, para a comparação entre as nuvens ser justa. Todo repositório é conferido por um harness
local que não precisa de conta de nuvem, e a plataforma inteira do lab v1 roda num cluster kind local
no CI. **Nada da v2 rodou numa nuvem ainda**: os caminhos de nuvem são código com testes.

Este repositório não tem infraestrutura nem app. Ele liga a família, guarda o roadmap detalhado do
que ainda falta para um lab completo nas três nuvens ([ROADMAP.md](ROADMAP.md)), as regras que os
sete repositórios seguem ([docs/GUARDRAILS.md](docs/GUARDRAILS.md)) e um harness que confere os seis
repositórios do lab uns contra os outros.

## A família

| Repositório | Nuvem | Papel | Status |
|---|---|---|---|
| `tx00v2` (este repositório) | as três | hub da família: roadmap, guardrails da família, checks entre os repositórios | veja as tabelas de status abaixo |
| [`tx01v2`](https://github.com/maringelix/tx01v2) | AWS | infraestrutura: Terraform, EKS, RDS PostgreSQL, ALB + WAF, camada de plataforma | veja a matriz de status dele |
| [`dx01v2`](https://github.com/maringelix/dx01v2) | AWS | aplicação: API Express 5 + TypeScript, React 19, PostgreSQL 17 | veja a matriz de status dele |
| [`tx02v2`](https://github.com/maringelix/tx02v2) | Azure | infraestrutura: Terraform, AKS, PostgreSQL Flexible Server, Application Gateway for Containers | veja a matriz de status dele |
| [`dx02v2`](https://github.com/maringelix/dx02v2) | Azure | aplicação: o mesmo app no AKS | veja a matriz de status dele |
| [`tx03v2`](https://github.com/maringelix/tx03v2) | GCP | infraestrutura: Terraform, GKE Autopilot, Cloud SQL, Cloud Armor | veja a matriz de status dele |
| [`dx03v2`](https://github.com/maringelix/dx03v2) | GCP | aplicação: o mesmo app no GKE Autopilot | veja a matriz de status dele |

Cada par conversa por um contrato versionado do repositório de infraestrutura (na AWS:
[docs/CONTRATO.md do tx01v2](https://github.com/maringelix/tx01v2/blob/main/docs/CONTRATO.md)); o
repositório de aplicação fixa o commit da infraestrutura que o e2e da plataforma usa
(`deploy/local/tx0Nv2.ref`).

## Por onde começar

1. Leia o par de referência: [tx01v2](https://github.com/maringelix/tx01v2) e
   [dx01v2](https://github.com/maringelix/dx01v2). Os pares da Azure e do Google Cloud são portes dele.
2. Rode o lab local, sem conta: `make e2e` no tx01v2 (Docker com 8 GB para o perfil `full`;
   [docs/LAB_LOCAL.md](https://github.com/maringelix/tx01v2/blob/main/docs/LAB_LOCAL.md)), depois
   `make e2e-platform` no dx01v2.
3. Escolha um item do [ROADMAP.md](ROADMAP.md); as regras de execução estão na seção 3 dele.
4. Fork do lab para um time: [FORK.md](FORK.md).

## Status do hub

| Capacidade | Status | Evidência |
|---|---|---|
| Checks do repositório: arquivos obrigatórios, identificadores, política dos workflows, links, formato do roadmap, actionlint, shellcheck, gitleaks | `verificado localmente` | `make static` num container `ubuntu:24.04` descartável em 2026-10-14; job de CI `static` |
| Checks da família: arquivos do padrão, tabelas da família, versões do contrato, refs fixadas, versões de ferramentas e charts, digests de imagens, arquivos idênticos, paridade do app, pins das actions, links e evidências dos docs do hub | `verificado localmente` | `make family` contra os seis repositórios em 2026-10-14; job de CI `family` (semanal) |
| Configurações do repositório como código (ruleset exigindo o `static`) | `planejado` | `scripts/repo-guardrails.sh` |
| Nuvem | não se aplica | o hub não fala com nuvem e não tem credenciais de nuvem |

## A família em um quadro (2026-10-14)

| Capacidade | Status | Onde |
|---|---|---|
| Harness, CI (`static`, `test`, `e2e`; nos apps também `images` e `e2e-platform`), rulesets, Dependabot, CI semanal | `verificado no CI` | os seis repositórios |
| A plataforma do v1 num lab kind local: Istio ambient, Gateway API + cert-manager, External Secrets, Prometheus, Alertmanager, Grafana, Loki, Argo CD, Gatekeeper, Trivy Operator, Velero, Chaos Mesh (34 sondas por repositório de infraestrutura) | `verificado no CI` | job `e2e` do tx01v2, do tx02v2 e do tx03v2 |
| O app nessa plataforma por GitOps (18 sondas por repositório de aplicação) | `verificado no CI` | job `e2e-platform` do dx01v2, do dx02v2 e do dx03v2 |
| Rodada 1: traces com OpenTelemetry (Collector + Tempo), alertas no Slack, chaos com hipóteses, rollout sem downtime | `verificado no CI` | ROADMAP.md, itens R1.1 a R1.6 |
| Caminhos de nuvem das três nuvens (bootstrap, apply, camada de plataforma, deploy, destroy + sobras) | `não executado em nuvem (v2)` | `docs/RUNBOOK.md` de cada repositório |
| DR, FinOps, SonarQube, OWASP ZAP, ACME, gerência de tráfego do Istio, a plataforma completa nas nuvens | `planejado` | [ROADMAP.md](ROADMAP.md) |

## Harness

Precisa de Linux ou WSL 2 com bash >= 4.4, curl, tar, xz, git e make.

```bash
git clone https://github.com/maringelix/tx00v2.git && cd tx00v2
make tools                     # actionlint, shellcheck, gitleaks e jq em .tools/ (SHA256 conferido)
HARNESS_STRICT=1 make verify   # o estágio static (job de CI static, obrigatório)
make family                    # checks entre os repositórios: clona a main dos seis
make help
```

| Target | O que roda | Quando |
|---|---|---|
| `make tools` | `scripts/install-tools.sh`: actionlint 1.7.12, shellcheck 0.11.0, gitleaks 8.30.1, jq 1.8.2 | uma vez, e depois de atualizar uma ferramenta |
| `make static` / `make verify` | `scripts/harness.sh static` | toda mudança (job de CI `static`) |
| `make family` | `scripts/harness.sh family` (rede, ou `FAMILY_SOURCE=<diretório com checkouts>`) | toda mudança e toda semana (job de CI `family`, informativo) |
| `make all` | static + family | antes de atualizar o roadmap |
| `make clean` | apaga `.tools/` e os dados temporários | quando quiser |

No Windows sem WSL, rode num container descartável (veja [docs/HARNESS.md](docs/HARNESS.md)).
`scripts/harness.sh list` mostra todos os checks.

## Documentação

| Doc | Conteúdo |
|---|---|
| [ROADMAP.md](ROADMAP.md) | tudo o que falta, item por item: status, repositórios, origem, entregáveis, aceite, custo, dependências; o mapa v1 → v2 e as decisões |
| [docs/GUARDRAILS.md](docs/GUARDRAILS.md) | as regras da família e onde cada uma é aplicada |
| [docs/HARNESS.md](docs/HARNESS.md) | os checks do hub, o que provam e o que não provam |
| [docs/HISTORICO.md](docs/HISTORICO.md) | o que foi feito, rodada por rodada, com os pull requests |
| [docs/SUSTENTACAO.md](docs/SUSTENTACAO.md) | rotinas do hub e o que fazer quando o `family` fica vermelho |
| [FORK.md](FORK.md) | fork da família (em inglês) |

Docs de referência do lab, no [tx01v2](https://github.com/maringelix/tx01v2):
[arquitetura](https://github.com/maringelix/tx01v2/blob/main/docs/ARQUITETURA.md),
[lab local](https://github.com/maringelix/tx01v2/blob/main/docs/LAB_LOCAL.md),
[runbook](https://github.com/maringelix/tx01v2/blob/main/docs/RUNBOOK.md),
[custos](https://github.com/maringelix/tx01v2/blob/main/docs/CUSTOS.md),
[sustentação](https://github.com/maringelix/tx01v2/blob/main/docs/SUSTENTACAO.md) e
[lições aprendidas do v1](https://github.com/maringelix/tx01v2/blob/main/docs/LICOES_APRENDIDAS.md).

## Contribuindo

Leia o [CONTRIBUTING.md](CONTRIBUTING.md) e o [AGENTS.md](AGENTS.md) (também para humanos).
Segurança: [SECURITY.md](SECURITY.md).

## Licença

[MIT](LICENSE) — Copyright (c) 2025-2026 Bruno Maringeli.
