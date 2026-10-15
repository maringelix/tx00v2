# Roadmap do lab DevOps v2: pronto para fork

Estado em 2026-10-15. Este arquivo é a fonte única do que falta para a família v2 ficar pronta: quem
fizer fork consegue rodar o lab inteiro no Docker da própria máquina e subir a infraestrutura, a
plataforma e o app nas próprias contas da AWS, da Azure e do Google Cloud, só com o código e o
`FORK.md` de cada repositório. Cada item diz o que entregar, como provar, quanto custa e do que
depende.

O harness deste repositório confere o formato: o check `roadmap` (`make static`, obrigatório no
ruleset) exige os campos de todo item, status válidos, repositórios conhecidos, dependências que
existem e a tabela da visão geral igual aos itens; o check `family-evidence` (`make family`) confere
que todo item `feito` aponta para pull requests mesclados.

## 1. O que é "pronto"

Decisão do Bruno em 2026-10-15 (DEC-11). O lab está pronto quando as quatro condições abaixo valem:

1. Lab local: toda capacidade de plataforma e de app tem uma sonda que roda no CI do repositório
   (`verificado no CI`), sem conta de nuvem, e o lab cabe num notebook (7 GB de Docker com
   `LOCAL_SIZE=small`, R1.8). Feito.
2. Nuvem como código: a plataforma que o lab local prova tem o código para as três nuvens, validado
   sem nuvem (render dos charts, kubeconform, `terraform test` com provider mockado, gator). Nada é
   homologado numa nuvem real: o rótulo continua `não executado em nuvem (v2)`, e quem faz fork roda
   na própria conta (R4).
3. Seguro para quem faz fork: scripts e workflows só mexem no que o lab criou, o destroy sempre chega
   ao fim, as identidades de CI ficam presas ao fork e à `main`, e nada identifica a pessoa nos logs
   públicos (R3).
4. Coerência da família: o `make family` deste repositório fica verde.

Faltam duas rodadas, uma por fase (R3 e R4), cada uma com um PR por repositório.

### Fora do escopo (DEC-11)

Estes temas saíram do roadmap; os textos completos estão no histórico do git (o `ROADMAP.md` do
commit `736bbb7`). Voltam só com um pedido do Bruno, como item novo.

- Rodadas reais nas nuvens, o rótulo `verificado na nuvem` e as perguntas que só a nuvem responde.
- O ensaio de fork com uma segunda conta do GitHub.
- DR: o perfil `dr` do lab local (região B, banco standby, failover, falha de nó), o DR na nuvem e o
  runbook de RTO e RPO.
- FinOps: OpenCost, labels de custo e showback, rightsizing com o VPA, spot e autoscaling de nós.
- HTTPS nas nuvens (pede um domínio) e o ACME local.
- Extras de segurança e qualidade: SonarQube, OWASP ZAP, Cloud Armor com a cobertura do v1, paridade
  dos WAFs, WAF no lab local, gerência de tráfego no Istio, SBOM e assinatura de imagens, CodeQL e
  checks novos nos rulesets.
- As propostas além do v1.

## 2. Onde estamos (2026-10-15)

Os seis repositórios são públicos, têm harness, CI semanal, Dependabot mensal, ruleset com checks
obrigatórios e rodam o lab local inteiro no CI. As fases R0 e R1 estão feitas. Nada da v2 rodou numa
nuvem.

| Repositório | Papel | Jobs obrigatórios | Lab local | Nuvem |
|---|---|---|---|---|
| [`tx01v2`](https://github.com/maringelix/tx01v2) | infraestrutura AWS | `static`, `test`, `e2e` | 34 sondas (`full`) | `não executado em nuvem (v2)` |
| [`dx01v2`](https://github.com/maringelix/dx01v2) | app na AWS | `static`, `test`, `images`, `e2e`, `e2e-platform` | 18 sondas na plataforma do tx01v2 | `não executado em nuvem (v2)` |
| [`tx02v2`](https://github.com/maringelix/tx02v2) | infraestrutura Azure | `static`, `test`, `e2e` | 34 sondas (`full`) | `não executado em nuvem (v2)` |
| [`dx02v2`](https://github.com/maringelix/dx02v2) | app na Azure | `static`, `test`, `images`, `e2e`, `e2e-platform` | 18 sondas na plataforma do tx02v2 | `não executado em nuvem (v2)` |
| [`tx03v2`](https://github.com/maringelix/tx03v2) | infraestrutura Google Cloud | `static`, `test`, `e2e` | 34 sondas (`full`) | `não executado em nuvem (v2)` |
| [`dx03v2`](https://github.com/maringelix/dx03v2) | app no Google Cloud | `static`, `test`, `images`, `e2e`, `e2e-platform` | 18 sondas na plataforma do tx03v2 | `não executado em nuvem (v2)` |
| [`tx00v2`](https://github.com/maringelix/tx00v2) | hub da família | `static` (`family` informativo) | não se aplica | não fala com nuvem |

O que o lab local de cada par já prova (`verificado no CI`): kind 1.36 com os gêmeos locais da nuvem
(registry, PostgreSQL 17 só com TLS, object storage, load balancer, servidor git), Istio 1.31 ambient
com mTLS `STRICT` e `AuthorizationPolicy` por identidade, Gateway API com HTTPS (cert-manager, CA do
lab), External Secrets, metrics-server, Prometheus, Alertmanager (alerta entregue também como
mensagem de Slack), Grafana, Loki + Alloy, Tempo e o OpenTelemetry Collector (trace do Gateway até a
query do PostgreSQL, `trace_id` nos logs, exemplars), Argo CD (commit, sync, self-heal), Gatekeeper
em `deny`, Trivy Operator, Velero (restore de namespace com dados) e Chaos Mesh com hipóteses (pod
kill, latência, stress, latência entre a API e o banco), além do rollout sem downtime do app.

O que existe só como código (`não executado em nuvem (v2)`): bootstrap (state, identidades OIDC ou
Workload Identity Federation, budget), apply do lab (rede, EKS/AKS/GKE Autopilot 1.36, PostgreSQL 17
gerenciado, registry, WAF, contrato), camada de plataforma mínima (controlador de entrada, ESO e
Collector com exportador de traces da nuvem), deploy do app e destroy com checagem de sobras.

Custos de referência de uma rodada de 3 horas com os padrões (fonte: `docs/CUSTOS.md` de cada
repositório de infraestrutura): AWS cerca de US$0,80 a 1,00
([CUSTOS do tx01v2](https://github.com/maringelix/tx01v2/blob/main/docs/CUSTOS.md)), Azure cerca de
US$1,50 ([CUSTOS do tx02v2](https://github.com/maringelix/tx02v2/blob/main/docs/CUSTOS.md)), Google
Cloud cerca de US$0,40 com o free tier da GKE e US$0,70 sem
([CUSTOS do tx03v2](https://github.com/maringelix/tx03v2/blob/main/docs/CUSTOS.md)).

## 3. Como ler e como executar

Campos de todo item: `Status`, `Repos`, `Origem`, `Dependências`, `Custo`, `Entregáveis`, `Aceite`
e, quando `feito`, `Evidência` (links dos PRs mesclados).

| Status | Significado |
|---|---|
| `feito` | mesclado com o CI verde; a evidência aponta os PRs |
| `em andamento` | PR aberto ou parte dos repositórios mesclada |
| `pendente` | aceito, ainda não começou |
| `bloqueado` | depende de algo fora dos repositórios (orçamento, conta, decisão) |
| `proposta` | além do v1; precisa do OK do Bruno antes de virar `pendente` |

| Origem | Significado |
|---|---|
| v1 implementado | o v1 tinha; a v2 precisa da paridade |
| v1 planejado | estava nos planos do v1 (as "Melhorias futuras" do tx01, as auditorias, a "Evolução Contínua" da apresentação pública do lab) e nunca foi feito |
| dívida v2 | encontrado ao construir a v2 |
| proposta v2 | não existia no v1 |

Regras de execução (as mesmas da v2 desde o início; detalhes em [docs/GUARDRAILS.md](docs/GUARDRAILS.md)):

1. Uma rodada por vez. O `tx01v2` e o `dx01v2` são a referência: o item nasce neles e é portado para
   o `tx02v2`/`tx03v2` e o `dx02v2`/`dx03v2` na mesma rodada, só com renomeações e o que a nuvem exige.
2. Um PR por repositório por rodada, com o CI verde antes do merge; o tx entra antes do dx, e o PR do
   dx fixa o commit mesclado do tx em `deploy/local/tx0Nv2.ref`.
3. Primeiro local, com sonda no CI; depois o código da nuvem, com testes, rótulo
   `não executado em nuvem (v2)` e o custo no `docs/CUSTOS.md`. Nada é aplicado numa nuvem sem um
   pedido explícito do Bruno para aquela ação.
4. Mudança de contrato: PRs coordenados nos dois lados e versão nova (`docs/CONTRATO.md`).
5. Nada de enfraquecer gate (`continue-on-error`, `|| true`, check pulado, ignore sem `statement` e
   `expired_at`), tudo fixado (versão + SHA256, SHA de 40 caracteres, digest).
6. Ao fim da rodada: este roadmap (status, evidência), o `docs/HISTORICO.md` e o `CHANGELOG.md` deste
   repositório, num commit só de documentação.

## 4. Visão geral

| ID | Item | Status |
|---|---|---|
| R0.1 | Os seis repositórios v2 públicos, com harness, CI e guardrails | `feito` |
| R0.2 | O mesmo app nos três pares (regra de paridade) | `feito` |
| R0.3 | Lab local com a plataforma completa do v1 | `feito` |
| R0.4 | O lab local como gate de merge | `feito` |
| R0.5 | Pronto para fork | `feito` |
| R0.6 | Hub da família (este repositório) | `feito` |
| R0.7 | Scripts que só agem no lab (segurança para quem faz fork) | `feito` |
| R1.1 | Traces na plataforma local | `feito` |
| R1.2 | Alertas no Slack | `feito` |
| R1.3 | Chaos com hipóteses: latência de rede e stress | `feito` |
| R1.4 | Traces no app e contrato v2 | `feito` |
| R1.5 | Rollout sem downtime e latência entre a API e o banco | `feito` |
| R1.6 | Exportadores de traces das nuvens, como código | `feito` |
| R1.7 | Dívida: SHA256 do chart do Collector na nuvem do tx01v2 | `feito` |
| R1.8 | Dívida: perfil enxuto do e2e-platform para máquinas com menos de 8 GB | `feito` |
| R1.9 | Dívida: instalação instável do servidor do Trivy Operator | `feito` |
| R1.10 | Dívida: timeout do webhook do ESO no lab local do tx03v2 | `feito` |
| R3.10 | Permission boundary no papel de apply da AWS | `pendente` |
| R3.13 | `leftovers.sh` da Azure e do Google Cloud só culpam o que é do lab | `pendente` |
| R3.14 | Destroy que sempre chega ao fim | `pendente` |
| R3.15 | OIDC e Workload Identity Federation presos a IDs imutáveis e à `main` | `pendente` |
| R3.16 | Papéis de CI mais estreitos fora de uma conta dedicada | `pendente` |
| R3.17 | Logs públicos sem identificadores e smoke sem token em texto puro | `pendente` |
| R3.18 | Efeitos colaterais na máquina de quem faz fork | `pendente` |
| R4.1 | Perfis `core` e `full` da camada de plataforma na nuvem | `pendente` |
| R4.2 | ADR: observabilidade no cluster ou gerenciada, por nuvem | `pendente` |
| R4.3 | Istio ambient nas três nuvens | `pendente` |
| R4.4 | Argo CD na nuvem e deploy do app por GitOps | `pendente` |
| R4.5 | Velero com o object storage de cada nuvem | `pendente` |
| R4.6 | Gatekeeper, Trivy Operator e Chaos Mesh na nuvem | `pendente` |
| R4.7 | Dimensionamento e custo do perfil `full` | `pendente` |
| R4.8 | Do fork à própria nuvem, de ponta a ponta | `pendente` |
| S.1 | Node.js 26 LTS nos apps | `pendente` |
| S.2 | Kubernetes 1.37 na família e kubectl alinhado | `pendente` |
| S.3 | Istio 1.31 para 1.33 | `pendente` |
| S.4 | Exceções do trivy que vencem em 2027-04-30 | `pendente` |
| S.5 | nginx 1.32 nos apps | `pendente` |
| S.6 | Amazon Linux 2023 nos nós do EKS | `pendente` |
| S.7 | Schemas de CRD do kubeconform | `pendente` |
| S.8 | Menções a "contract v1" que descrevem a versão 2 | `feito` |
| S.9 | Primeira revisão trimestral conjunta da família | `pendente` |

## 5. As duas rodadas que faltam

```mermaid
flowchart LR
  R0["R0 fundação (feito)"] --> R1["R1 observabilidade 2.0, alertas, chaos, rollout (feito)"]
  R1 --> R3["R3 segurança para quem faz fork"]
  R3 --> R4["R4 plataforma completa na nuvem (código) e o caminho do fork"]
  S["S sustentação e calendário"] -.-> R4
```

1. R3: R3.10 e R3.13 a R3.18, nos seis repositórios de lab.
2. R4: R4.1 a R4.8, nos seis repositórios de lab. O R4.8 fecha o caminho do fork até a própria nuvem.

Os itens S entram quando a data chega (uma versão nova, uma exceção que vence), fora das duas
rodadas.

## R0. Fundação da v2

### R0.1 Os seis repositórios v2 públicos, com harness, CI e guardrails

- Status: `feito`
- Repos: tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: dívida v2 (reconstrução do v1 com prova local e rótulos honestos)
- Dependências: nenhuma
- Custo: nenhum (GitHub Actions de repositórios públicos)
- Entregáveis:
  - `scripts/harness.sh` com estágios `static`, `test` e, nos dx, `build` e `e2e` (kind); ferramentas
    fixadas por versão e SHA256 (`tools/`), actions por SHA de 40 caracteres, imagens por digest.
  - CI = harness (`ci.yml` só chama `make`), `HARNESS_STRICT=1`, CI semanal, Dependabot mensal.
  - Ruleset como código (`.github/rulesets/main.json`) e `scripts/repo-guardrails.sh`, aplicado e
    lido de volta com `gh api` em 2026-10-14.
  - Docs em pt-BR (arquitetura, contrato, runbook, custos, guardrails, harness, sustentação,
    publicação, lições do v1).
- Aceite:
  - CI verde nos seis; linhas `verificado no CI` só depois do primeiro CI verde.
- Evidência: [tx01v2#1](https://github.com/maringelix/tx01v2/pull/1), [dx01v2#3](https://github.com/maringelix/dx01v2/pull/3), [tx02v2#1](https://github.com/maringelix/tx02v2/pull/1), [dx02v2#1](https://github.com/maringelix/dx02v2/pull/1), [tx03v2#1](https://github.com/maringelix/tx03v2/pull/1), [dx03v2#3](https://github.com/maringelix/dx03v2/pull/3), [tx01v2#2](https://github.com/maringelix/tx01v2/pull/2), [tx01v2#3](https://github.com/maringelix/tx01v2/pull/3), [tx02v2#2](https://github.com/maringelix/tx02v2/pull/2), [tx03v2#2](https://github.com/maringelix/tx03v2/pull/2)

### R0.2 O mesmo app nos três pares (regra de paridade)

- Status: `feito`
- Repos: dx01v2, dx02v2, dx03v2
- Origem: dívida v2 (no v1 cada nuvem tinha um app diferente: Node 20 com PostgreSQL, SQL Server, TypeScript com Tailwind)
- Dependências: R0.1
- Custo: nenhum
- Entregáveis:
  - O app do `dx01v2` (commit `22e69c4`: Express 5 + TypeScript, React 19 em nginx-unprivileged,
    PostgreSQL 17) nos três repositórios de app; só o alvo de deploy muda.
  - Regra de paridade no `AGENTS.md` de cada dx e rotina no `docs/SUSTENTACAO.md`.
  - Os casos de teste de `X-Forwarded-For` do AGC e do load balancer do Google portados para os três.
- Aceite:
  - O check `family-app` deste repositório: mesmas dependências e o mesmo código em `api/src` e
    `web/src`, a menos de nomes e comentários.
- Evidência: [dx01v2#4](https://github.com/maringelix/dx01v2/pull/4), [dx01v2#5](https://github.com/maringelix/dx01v2/pull/5), [dx02v2#2](https://github.com/maringelix/dx02v2/pull/2), [dx03v2#4](https://github.com/maringelix/dx03v2/pull/4)

### R0.3 Lab local com a plataforma completa do v1

- Status: `feito`
- Repos: tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: v1 implementado (a plataforma do v1 só existia na nuvem, instalada por workflows)
- Dependências: R0.1
- Custo: local, grátis; 8 GB de memória do Docker para o perfil `full` (3 GB para o `core`)
- Entregáveis:
  - `terraform/envs/local` (provider Docker): kind, gêmeos locais do registry, do banco (PostgreSQL 17
    só com TLS), do object storage, do load balancer e do GitHub (servidor git).
  - `platform/local` com perfis `core`, `observability`, `operations` e `full`, contrato local
    (`lab-system/lab-contract`), `check.sh` com as sondas e `uninstall.sh` sem sobras.
  - Nos dx: overlay `local-platform`, `scripts/deploy-local.sh` (GitOps pelo Argo CD) e
    `scripts/e2e-platform.sh`.
- Aceite:
  - `make e2e` (tx) e `make e2e-platform` (dx) verdes no CI, com destroy e checagem de sobras.
- Evidência: [tx01v2#5](https://github.com/maringelix/tx01v2/pull/5), [tx01v2#6](https://github.com/maringelix/tx01v2/pull/6), [tx02v2#3](https://github.com/maringelix/tx02v2/pull/3), [tx02v2#4](https://github.com/maringelix/tx02v2/pull/4), [tx03v2#3](https://github.com/maringelix/tx03v2/pull/3), [dx01v2#6](https://github.com/maringelix/dx01v2/pull/6), [dx02v2#3](https://github.com/maringelix/dx02v2/pull/3), [dx03v2#5](https://github.com/maringelix/dx03v2/pull/5)

### R0.4 O lab local como gate de merge

- Status: `feito`
- Repos: tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: dívida v2
- Dependências: R0.3
- Custo: cerca de 30 a 50 minutos de runner por PR (gratuito em repositórios públicos)
- Entregáveis:
  - Jobs `e2e` (tx) e `e2e-platform` (dx) exigidos pelo ruleset, aplicados com
    `scripts/repo-guardrails.sh`.
- Aceite:
  - O ruleset lido de volta com `gh api` lista os jobs; o check `family-identical` exige o mesmo
    ruleset dentro de cada papel.
- Evidência: [tx01v2#7](https://github.com/maringelix/tx01v2/pull/7), [tx02v2#5](https://github.com/maringelix/tx02v2/pull/5), [tx03v2#4](https://github.com/maringelix/tx03v2/pull/4), [dx01v2#7](https://github.com/maringelix/dx01v2/pull/7), [dx02v2#4](https://github.com/maringelix/dx02v2/pull/4), [dx03v2#6](https://github.com/maringelix/dx03v2/pull/6)

### R0.5 Pronto para fork

- Status: `feito`
- Repos: tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: dívida v2 (o time do Bruno aprende fazendo fork dos pares)
- Dependências: R0.1
- Custo: nenhum
- Entregáveis:
  - `FORK.md` em cada repositório: o que o GitHub não copia, o lab local, a própria conta de nuvem.
  - `github_owner` sem valor padrão nos bootstraps; `repo-guardrails.sh` liga issues, aprovação de
    runs de forks e para com uma mensagem clara enquanto as Actions do fork estão desligadas.
  - O e2e-platform dos dx clona o repositório tx configurado (`TX0NV2_REPO`).
- Aceite:
  - Devcontainers verificados com `LOCAL_PROFILE=core make e2e` dentro (2026-10-14); o ensaio com uma
    segunda conta do GitHub ficou fora do escopo (DEC-11).
- Evidência: [tx01v2#8](https://github.com/maringelix/tx01v2/pull/8), [tx02v2#6](https://github.com/maringelix/tx02v2/pull/6), [tx03v2#5](https://github.com/maringelix/tx03v2/pull/5), [dx01v2#8](https://github.com/maringelix/dx01v2/pull/8), [dx02v2#5](https://github.com/maringelix/dx02v2/pull/5), [dx03v2#7](https://github.com/maringelix/dx03v2/pull/7)

### R0.6 Hub da família (este repositório)

- Status: `feito`
- Repos: tx00v2, tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: proposta v2 (no v1, o `tx00` era um rastreador privado de auditorias)
- Dependências: R0.1
- Custo: nenhum
- Entregáveis:
  - Este repositório: README com as referências, este roadmap, guardrails da família
    ([docs/GUARDRAILS.md](docs/GUARDRAILS.md)), harness com os estágios `static` (obrigatório) e
    `family` (os checks entre os repositórios), histórico ([docs/HISTORICO.md](docs/HISTORICO.md)).
  - A linha do `tx00v2` na tabela da família dos seis READMEs.
- Aceite:
  - CI verde (`static` e `family`), ruleset aplicado e lido de volta; o check `family-table` acha o
    hub nos doze READMEs dos seis repositórios.
- Evidência: [tx01v2#10](https://github.com/maringelix/tx01v2/pull/10), [dx01v2#10](https://github.com/maringelix/dx01v2/pull/10), [tx02v2#8](https://github.com/maringelix/tx02v2/pull/8), [tx03v2#6](https://github.com/maringelix/tx03v2/pull/6), [dx02v2#6](https://github.com/maringelix/dx02v2/pull/6), [dx03v2#8](https://github.com/maringelix/dx03v2/pull/8)

### R0.7 Scripts que só agem no lab (segurança para quem faz fork)

- Status: `feito`
- Repos: tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: auditoria de segurança para forks (2026-10-14): o que poderia quebrar a máquina ou a nuvem
  de quem faz fork
- Dependências: R0.5
- Custo: nenhum
- Entregáveis:
  - Os scripts de nuvem não escolhem o alvo por variável de ambiente genérica (`CLUSTER_NAME`,
    `RESOURCE_GROUP`, `LAB_*`): o alvo vem do contrato e é conferido pela tag `Project` (AWS, Azure)
    ou pelo label `project` (Google Cloud) do cluster antes de qualquer mudança (`require_lab_cluster`).
  - Kubeconfig de nuvem em arquivo temporário nos scripts e num arquivo próprio nos outputs e nos
    runbooks: o `~/.kube/config` e o contexto atual de quem roda não mudam, e o kubelogin da Azure só
    converte esse arquivo.
  - Os scripts de `platform/local` e o `scripts/deploy-local.sh` só falam com o contexto
    `kind-tx0Nv2-local` (`require_lab_context`).
  - Os testes de integração dos apps, que apagam e recriam tabelas, só aceitam um banco cujo nome
    termina em `_test` (no helper e no harness); os runbooks mostram um banco `*_test` separado.
  - O `leftovers.sh` da AWS só conta como sobra o Elastic IP com a tag do lab; o PostgreSQL da Azure
    leva o sufixo da assinatura no nome (nome DNS global, que bloqueava o apply do lab de outro fork).
  - Check estático `policy-scripts` nos três tx (SEC-10, SEC-14 e SEC-16 nos guardrails de cada um),
    SEC-07, SEC-08 e SEC-09 nos dx e a regra SEC-05 da família.
- Aceite:
  - `HARNESS_STRICT=1 make verify` local e CI verde nos seis (`static`, `test`, `e2e`; nos dx também
    `images` e `e2e-platform`); a trava do banco provada nos dois sentidos (aceita `dx01v2_test`,
    recusa `dx01v2` antes de conectar, no harness e no vitest direto).
- Evidência: [tx01v2#11](https://github.com/maringelix/tx01v2/pull/11), [tx02v2#9](https://github.com/maringelix/tx02v2/pull/9), [tx03v2#8](https://github.com/maringelix/tx03v2/pull/8), [dx01v2#11](https://github.com/maringelix/dx01v2/pull/11), [dx02v2#7](https://github.com/maringelix/dx02v2/pull/7), [dx03v2#9](https://github.com/maringelix/dx03v2/pull/9)

## R1. Observabilidade 2.0, alertas, chaos e rollout sem downtime

A rodada que trouxe o que faltava do v1 na observabilidade e a última etapa do roadmap do v1 que
nunca começou ("Observability 2.0", com OpenTelemetry). Contrato local e de nuvem na versão 2 (a
chave nova é o endpoint OTLP do Collector).

### R1.1 Traces na plataforma local

- Status: `feito`
- Repos: tx01v2, tx02v2, tx03v2
- Origem: v1 planejado ("Observability 2.0" com OpenTelemetry; o v1 tinha só Application Insights e o Jaeger do Istio)
- Dependências: R0.3
- Custo: local, cerca de 0,5 GB a mais no perfil `observability`
- Entregáveis:
  - OpenTelemetry Collector (chart 0.176.0, imagem contrib por digest) e Tempo (chart
    `grafana-community/tempo` 3.1.0) no perfil `observability`.
  - Spans do Istio Gateway pela Telemetry API, com W3C trace context; `extensionProviders` no istiod.
  - Conector spanmetrics com exemplars e ServiceMonitor de 10 s (o exemplar vive um flush de 15 s).
  - Datasources do Grafana ligando Tempo, Loki e Prometheus.
- Aceite:
  - Sonda `check_tracing`: trace OTLP no Tempo, span do Gateway, métrica do spanmetrics com
    exemplar, links do Grafana; 22 sondas no perfil `observability` e 34 no `full`.
- Evidência: [tx01v2#9](https://github.com/maringelix/tx01v2/pull/9), [tx02v2#7](https://github.com/maringelix/tx02v2/pull/7), [tx03v2#6](https://github.com/maringelix/tx03v2/pull/6)

### R1.2 Alertas no Slack

- Status: `feito`
- Repos: tx01v2, tx02v2, tx03v2
- Origem: v1 implementado (Alertmanager com receivers do Slack nas três nuvens)
- Dependências: R0.3
- Custo: nenhum
- Entregáveis:
  - Receiver do Slack no Alertmanager com o webhook lido de um Secret opcional; sem o Secret, nada
    sai do cluster.
  - No CI, o webhook aponta para o alert sink do lab, que guarda o payload.
- Aceite:
  - Sonda `check_slack`: o alerta sintético chega no formato de mensagem do Slack.
- Evidência: [tx01v2#9](https://github.com/maringelix/tx01v2/pull/9), [tx02v2#7](https://github.com/maringelix/tx02v2/pull/7), [tx03v2#6](https://github.com/maringelix/tx03v2/pull/6)

### R1.3 Chaos com hipóteses: latência de rede e stress

- Status: `feito`
- Repos: tx01v2, tx02v2, tx03v2
- Origem: v1 implementado (Chaos Mesh manual no tx02 do v1: pod, latência, CPU e memória)
- Dependências: R0.3
- Custo: nenhum
- Entregáveis:
  - NetworkChaos de 100 ms e StressChaos de CPU e memória, cada um com hipótese escrita e medida.
- Aceite:
  - Sondas do perfil `operations` (24): a mediana da latência sobe como previsto, o pico de CPU e
    memória aparece nas métricas e nenhum container reinicia.
- Evidência: [tx01v2#9](https://github.com/maringelix/tx01v2/pull/9), [tx02v2#7](https://github.com/maringelix/tx02v2/pull/7), [tx03v2#6](https://github.com/maringelix/tx03v2/pull/6)

### R1.4 Traces no app e contrato v2

- Status: `feito`
- Repos: dx01v2, dx02v2, dx03v2
- Origem: v1 planejado ("Observability 2.0")
- Dependências: R1.1
- Custo: nenhum
- Entregáveis:
  - Spans manuais na API (SERVER por requisição com o nome da rota, CLIENT por query do PostgreSQL,
    só SQL parametrizado), `traceparent` continuado, OTLP/HTTP para `OTEL_EXPORTER_OTLP_ENDPOINT`
    (desligado sem ele), `trace_id`/`span_id` nos logs, OpenMetrics com o trace id como exemplar,
    flush de no máximo 5 s no desligamento.
  - Dependências fixadas: `@opentelemetry/api` 1.9.1, `sdk-trace-node` 2.12.0,
    `exporter-trace-otlp-http` 0.223.0, `resources` 2.12.0, `semantic-conventions` 1.43.0.
  - Contrato v2: `deploy-local.sh` exige a versão 2 do contrato local e espera o sync do commit que
    enviou; NetworkPolicies API → Collector (4318) e Gateway → Collector (4317), as duas por HBONE
    (15008); o componente de nuvem manda os traces para `observability:4318`.
- Aceite:
  - Sonda de traces do `e2e-platform`: um trace no Tempo do Gateway até a query, o `trace_id` no Loki
    e num exemplar; testes de unidade e integração com o processador em memória.
- Evidência: [dx01v2#9](https://github.com/maringelix/dx01v2/pull/9), [dx02v2#6](https://github.com/maringelix/dx02v2/pull/6), [dx03v2#8](https://github.com/maringelix/dx03v2/pull/8)

### R1.5 Rollout sem downtime e latência entre a API e o banco

- Status: `feito`
- Repos: dx01v2, dx02v2, dx03v2
- Origem: v1 implementado (rolling update e PDB no v1, sem prova de zero erro)
- Dependências: R1.4
- Custo: nenhum
- Entregáveis:
  - `check_zero_downtime`: um redeploy por GitOps com uma tag nova enquanto um leitor faz requisições.
  - `check_chaos_db_latency`: NetworkChaos de 200 ms entre a API e o PostgreSQL.
- Aceite:
  - O leitor termina sem nenhuma requisição com erro; o span do `SELECT` mostra pelo menos 190 ms
    sob o chaos e as leituras continuam; 18 sondas no `e2e-platform`.
- Evidência: [dx01v2#9](https://github.com/maringelix/dx01v2/pull/9), [dx02v2#6](https://github.com/maringelix/dx02v2/pull/6), [dx03v2#8](https://github.com/maringelix/dx03v2/pull/8)

### R1.6 Exportadores de traces das nuvens, como código

- Status: `feito`
- Repos: tx01v2, tx02v2, tx03v2
- Origem: v1 planejado ("Observability 2.0" nas nuvens)
- Dependências: R1.1
- Custo: AWS X-Ray com 100 mil traces por mês sem custo; Cloud Trace com 2,5 milhões de spans por
  mês sem custo; Application Insights com teto de 0,5 GB por dia (detalhes nos `docs/CUSTOS.md`)
- Entregáveis:
  - AWS: exportador `awsxray` e papel do Pod Identity do Collector com `AWSXRayDaemonWriteAccess`.
  - Azure: Application Insights sempre ligado (DEC-6), autenticação local desligada, identidade
    federada do Collector com o papel Monitoring Metrics Publisher, extensão `azure_auth` e exportador
    `azure_monitor`.
  - Google Cloud: exportador `googlecloud`, `roles/cloudtrace.agent` para o principal do service
    account do Kubernetes do Collector e a API do Cloud Trace no bootstrap.
- Aceite:
  - `terraform test` e `helm template` no CI (`verificado no CI`); a nuvem continua
    `não executado em nuvem (v2)`. Antes da primeira rodada, reaplicar os bootstraps do tx02v2 (lista
    do ABAC) e do tx03v2 (API do Cloud Trace).
- Evidência: [tx01v2#9](https://github.com/maringelix/tx01v2/pull/9), [tx02v2#7](https://github.com/maringelix/tx02v2/pull/7), [tx03v2#6](https://github.com/maringelix/tx03v2/pull/6)

### R1.7 Dívida: SHA256 do chart do Collector na nuvem do tx01v2

- Status: `feito`
- Repos: tx01v2
- Origem: dívida v2 (achada no porte da R1)
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - O SHA256 do arquivo do chart do Collector sai de `platform/local/versions.env`
    (`OTEL_COLLECTOR_SHA256`) e vai para `platform/versions.env` como `OTEL_COLLECTOR_CHART_SHA256`,
    usado pela nuvem e pelo lab local, como no tx02v2 e no tx03v2.
  - `platform/install.sh` baixa o arquivo, confere o SHA256 e instala a partir dele.
- Aceite:
  - `helm-template` e `local-versions` verdes; o `family-versions` mostra a mesma chave nos três tx.
- Evidência: [tx01v2#12](https://github.com/maringelix/tx01v2/pull/12) (o `dx01v2` seguiu o commit em [dx01v2#12](https://github.com/maringelix/dx01v2/pull/12))

### R1.8 Dívida: perfil enxuto do e2e-platform para máquinas com menos de 8 GB

- Status: `feito`
- Repos: tx01v2, tx02v2, tx03v2, dx01v2, dx02v2, dx03v2
- Origem: dívida v2 (o perfil `full` com o app passa dos 7,65 GiB do Docker Desktop usado no desenvolvimento; as sondas novas da R1 só rodaram no CI)
- Dependências: R1.5
- Custo: local, grátis; o objetivo é caber em 6 GB
- Entregáveis:
  - Um perfil de recursos `small` no `platform/local/install.sh` (requests e limits menores, uma
    réplica por componente, retenção curta no Prometheus, no Loki e no Tempo), escolhido por variável;
    os componentes continuam os mesmos, porque as sondas do app usam quase todos.
  - O `scripts/e2e-platform.sh` dos dx aceita o perfil e o `docs/LAB_LOCAL.md` diz quanto cada perfil
    precisa, medido.
- Aceite:
  - As 18 sondas passam com o Docker limitado a 6 GB (rodada local registrada nos `docs/LAB_LOCAL.md`);
    o CI continua com o perfil padrão.
  - Mudado em 2026-10-15, depois da medição: 7 GB em vez de 6 GB (decisão do Bruno) e a prova no CI,
    não numa rodada local (o lab pesado não roda mais na máquina de desenvolvimento). O job
    `e2e-platform-small` dos dx roda o `e2e-platform` com `LOCAL_SIZE=small` num Docker-in-Docker
    limitado a 7 GB, sem swap; não é check exigido, e o `e2e-platform` no tamanho padrão continua o
    portão.
- Evidência: [tx01v2#13](https://github.com/maringelix/tx01v2/pull/13), [dx01v2#13](https://github.com/maringelix/dx01v2/pull/13), [tx02v2#11](https://github.com/maringelix/tx02v2/pull/11), [dx02v2#9](https://github.com/maringelix/dx02v2/pull/9), [tx03v2#10](https://github.com/maringelix/tx03v2/pull/10), [dx03v2#11](https://github.com/maringelix/dx03v2/pull/11). Medido no CI do dx01v2: em 6 GB, 14 das 18 sondas passam e a de rollout perde 7
  de 376 requisições; em 7 GB e em 8 GB, as 18 passam em cerca de 14 minutos, com 4,4 GiB de memória
  anônima. Em 7 GB, as 18 sondas passaram nas nove rodadas dos três pares; em duas delas o kernel matou
  duas vezes a cópia do plugin do Velero na instalação (init container sem requests, que o kubelet
  roda de novo). O maior consumidor é o apiserver, com cerca de 1,2 GiB, mesmo com `GOMEMLIMIT`. A retenção
  do Loki ficou como estava: o lab vive menos de uma hora e ela não muda a memória. O padrão já tinha
  uma réplica de cada componente.

### R1.9 Dívida: instalação instável do servidor do Trivy Operator

- Status: `feito`
- Repos: tx01v2, tx02v2, tx03v2
- Origem: dívida v2 (uma rodada do `e2e` do tx01v2#9, em 2026-10-14, falhou na instalação: o pod `trivy-server-0` terminou em `Failed` e o Helm reverteu o release; a seguinte passou. O diagnóstico de instalação ainda não existia, então não há dados do pod)
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - Com o diagnóstico de instalação já adicionado, achar a causa se a falha voltar (recursos, probes
    ou o cache do servidor no modo ClientServer) e corrigir nos values dos três tx.
- Aceite:
  - Dez rodadas seguidas do job `e2e` verdes nos três tx (PRs e CI semanal), ou a causa documentada
    no `docs/LICOES_APRENDIDAS.md` com a correção.
  - Contagem em 2026-10-15: 8 seguidas no tx01v2, 18 no tx02v2 e 15 no tx03v2; a falha não voltou.
- Evidência: [tx01v2#13](https://github.com/maringelix/tx01v2/pull/13), [tx02v2#11](https://github.com/maringelix/tx02v2/pull/11), [tx03v2#10](https://github.com/maringelix/tx03v2/pull/10). No fim da R1.8 (2026-10-15), o job
  `e2e` estava com 11 rodadas verdes seguidas no tx01v2, 20 no tx02v2 e 18 no tx03v2, contando PRs e
  pushes para a `main` (uma rodada cancelada por um push novo não conta). A falha não voltou, então não
  houve causa a corrigir; se voltar, o diagnóstico de instalação guarda os dados do pod.

### R1.10 Dívida: timeout do webhook do ESO no lab local do tx03v2

- Status: `feito`
- Repos: tx03v2
- Origem: dívida v2 (duas rodadas locais do perfil `observability` falharam na sonda do External Secrets com `context deadline exceeded` no webhook; o CI passou)
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - Os values locais do ESO sem os limites de CPU do Autopilot (50m no webhook e no cert controller,
    100m no controller), que hoje vêm de `platform/values/external-secrets.yaml`; requests menores.
- Aceite:
  - Três rodadas locais seguidas do perfil `observability` verdes num Docker de 8 GB, sem mudar a
    sonda.
- Evidência: [tx03v2#9](https://github.com/maringelix/tx03v2/pull/9) (as três rodadas locais, 22 de 22 sondas cada, estão num comentário do PR), [dx03v2#10](https://github.com/maringelix/dx03v2/pull/10)

## R3. Segurança para quem faz fork

O resto da auditoria de segurança para forks de 2026-10-14 (a parte local entrou em R0.7). Primeira
das duas rodadas que faltam.

### R3.10 Permission boundary no papel de apply da AWS

- Status: `pendente`
- Repos: tx01v2
- Origem: dívida v2 (`planejado` no `docs/GUARDRAILS.md` do tx01v2; o papel de apply pode criar papéis `tx01v2-*`)
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - Uma política de permission boundary obrigatória em todo papel que o apply cria (condição
    `iam:PermissionsBoundary` no papel do apply), aplicada no bootstrap.
- Aceite:
  - `terraform test` prova a condição e o boundary em todos os papéis do lab; reaplicar o bootstrap
    antes da próxima rodada.

### R3.13 `leftovers.sh` da Azure e do Google Cloud só culpam o que é do lab

- Status: `pendente`
- Repos: tx02v2, tx03v2
- Origem: auditoria de segurança para forks (2026-10-14); a parte da AWS entrou em R0.7
- Dependências: R0.7
- Custo: nenhum
- Entregáveis:
  - Só conta como sobra o que tem a tag `Project=tx02v2` ou está nos grupos `tx02v2-*`, e o que tem o
    label `project=tx03v2` ou está na rede `tx03v2-lab` (forwarding rules, NEGs, firewalls); o resto
    aparece como `INFO` ("not the lab's"), nunca como algo a apagar.
  - `--subscription` explícita na Azure, sem depender do `az account set` da máquina.
  - A seção 9 dos RUNBOOKs só dá comandos de remoção para itens do lab.
- Aceite:
  - Um teste offline com `az` e `gcloud` simulados (como o do `deploy-gcp.sh` do dx03v2) prova a
    classificação numa assinatura e num projeto que também têm recursos de outro trabalho.

### R3.14 Destroy que sempre chega ao fim

- Status: `pendente`
- Repos: tx01v2, tx02v2, tx03v2
- Origem: auditoria de segurança para forks (2026-10-14)
- Dependências: nenhuma
- Custo: nenhum (evita um lab esquecido cobrando)
- Entregáveis:
  - Se o `platform/uninstall.sh` falha (API do cluster inalcançável, controlador parado, timeout), o
    workflow de destroy remove pela API da nuvem os load balancers que o cluster criou (pela tag ou
    pelo nome do lab) e segue para o `terraform destroy`; a checagem de sobras roda com `if: always()`.
  - Input de `force-unlock` no workflow de destroy e a recuperação de um apply interrompido documentada
    (lock do S3, lease do blob, lock do GCS, import do que ficou fora do state).
  - Na Azure, o comando exato de purge do Key Vault no fim do destroy (o soft delete de 7 dias prende o
    nome para a rodada seguinte).
- Aceite:
  - Um teste offline com as CLIs simuladas mostra que um uninstall que falha ainda leva ao destroy e
    à checagem de sobras.

### R3.15 OIDC e Workload Identity Federation presos a IDs imutáveis e à `main`

- Status: `pendente`
- Repos: tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: auditoria de segurança para forks (2026-10-14)
- Dependências: nenhuma
- Custo: nenhum (reaplicar os três bootstraps)
- Entregáveis:
  - A confiança dos papéis e das identidades de CI inclui `repository_owner_id` e `repository_id` (um
    nome de conta apagado e registrado de novo não herda o lab) e só a `main` com o environment `lab`
    (customização do `sub` do OIDC, ou `attribute_condition` no Google Cloud).
  - O `repo-guardrails.sh` falha, em vez de pular, quando não consegue proteger o environment `lab`
    (hoje só um repositório público recebe a proteção).
- Aceite:
  - `terraform test` prova os sujeitos e as condições; o `FORK.md` explica de onde vêm os IDs.

### R3.16 Papéis de CI mais estreitos fora de uma conta dedicada

- Status: `pendente`
- Repos: tx01v2, tx02v2, tx03v2
- Origem: auditoria de segurança para forks (2026-10-14)
- Dependências: R3.10
- Custo: nenhum
- Entregáveis:
  - Google Cloud: o apply sem `roles/editor`, `secretmanager.admin` e `iam.serviceAccountUser` no
    projeto inteiro (papéis presos aos recursos `tx03v2-lab-*` e à conta de serviço dos nós) e um
    pre-flight que recusa um projeto com clusters, instâncias SQL ou segredos de outro trabalho.
  - AWS: o plan com uma política de leitura presa aos serviços do lab, no lugar do `ReadOnlyAccess` da
    conta inteira; o provider OIDC do GitHub lido por data source quando já existe e nunca apagado no
    teardown (o permission boundary do apply é o R3.10).
  - Azure: a identidade do plan sem leitura dos valores dos segredos.
- Aceite:
  - `terraform test` prova as permissões; os docs dizem o que ainda exige conta, assinatura ou projeto
    dedicados ao lab.

### R3.17 Logs públicos sem identificadores e smoke sem token em texto puro

- Status: `pendente`
- Repos: tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: auditoria de segurança para forks (2026-10-14)
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - Mascarar nos logs e nos artefatos públicos dos workflows de nuvem os CIDRs (o IP de casa de quem
    faz fork), os object IDs e os e-mails, além dos IDs que já são trocados.
  - O smoke em nuvem não manda o token de admin por HTTP puro: pula as chamadas de admin (o HTTPS nas
    nuvens ficou fora do escopo, DEC-11).
- Aceite:
  - O `policy-workflows` prova as máscaras; o plan de exemplo do CI sai sem esses valores.

### R3.18 Efeitos colaterais na máquina de quem faz fork

- Status: `pendente`
- Repos: tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: auditoria de segurança para forks (2026-10-14)
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - Pre-flight do lab local: CIDR da rede Docker que colide com uma rota da máquina (VPN, LAN), porta
    do registry ocupada, `DOCKER_HOST` ou contexto do Docker diferente do daemon do provider.
  - `LOCAL_STATE_DIR` separado entre o `make e2e` do tx e o `e2e-platform` do dx (hoje um destrói o
    lab mantido pelo outro).
  - `make clean` sempre relativo ao diretório do Makefile; diagnósticos do `e2e-platform` só pelo
    kubeconfig do lab; guarda de variável vazia no `rm -rf` do `scripts/lib/k8s.sh` do dx02v2; o
    `repo-guardrails.sh` confere que o argumento é o fork certo.
  - Google Cloud: budget com `credit_types_treatment = "EXCLUDE_ALL_CREDITS"` (créditos de trial
    escondem o gasto) e destinatários explícitos; `DOCKER_CONFIG` temporário no deploy; o RUNBOOK
    recomenda uma configuração do gcloud só para o lab, porque o `application-default login`
    sobrescreve o ADC da máquina.
- Aceite:
  - Cada entregável com um teste ou um check do harness; os docs dizem o que continua exigindo uma
    máquina sem outro trabalho.

## R4. A plataforma completa nas nuvens (como código)

Hoje a camada de plataforma da nuvem instala só o mínimo (controlador de entrada, ESO e Collector);
os READMEs dos três tx dizem `planejado` para "os mesmos add-ons no EKS/AKS/GKE". Esta fase leva o
que o lab local prova para a nuvem, com as mesmas versões e digests, sempre opcional e com custo
escrito. É a segunda das duas rodadas que faltam; nada daqui é aplicado numa nuvem (DEC-11).

### R4.1 Perfis `core` e `full` da camada de plataforma na nuvem

- Status: `pendente`
- Repos: tx01v2, tx02v2, tx03v2
- Origem: v1 implementado (os add-ons do v1 eram instalados por workflows nas três nuvens)
- Dependências: nenhuma
- Custo: o perfil `full` precisa de mais nós ou nós maiores (R4.7); o `core` continua o padrão
- Entregáveis:
  - `platform/install.sh --profile core|full`: o `full` acrescenta Istio, cert-manager,
    kube-prometheus-stack, Loki + Alloy, Tempo, Argo CD, Gatekeeper, Trivy Operator, Velero e Chaos
    Mesh, com as versões e digests do lab local e values por nuvem em `platform/values/`.
  - Identidades por componente (Pod Identity, Workload ID, Workload Identity Federation) só onde o
    componente fala com a nuvem.
- Aceite:
  - `helm-template`, `kubeconform` e `contract-platform` renderizam e validam o perfil `full` das três
    nuvens no CI; `não executado em nuvem (v2)`.

### R4.2 ADR: observabilidade no cluster ou gerenciada, por nuvem

- Status: `pendente`
- Repos: tx01v2, tx02v2, tx03v2
- Origem: dívida v2
- Dependências: nenhuma
- Custo: o ADR compara o custo por rodada das duas opções
- Entregáveis:
  - ADR no `docs/ARQUITETURA.md` de cada tx: kube-prometheus-stack, Loki e Tempo no cluster contra
    Amazon Managed Service for Prometheus + Managed Grafana + CloudWatch, Azure Monitor (Prometheus
    gerenciado) + Managed Grafana + Log Analytics, e Google Cloud Managed Service for Prometheus +
    Cloud Logging + Cloud Trace; o que cada opção deixa as sondas provarem.
- Aceite:
  - ADR mesclado nos três, com a decisão e o custo; o perfil `full` da R4.1 segue a decisão.

### R4.3 Istio ambient nas três nuvens

- Status: `pendente`
- Repos: tx01v2, tx02v2, tx03v2
- Origem: v1 implementado (Istio no AKS e no GKE do v1, com mTLS `PERMISSIVE`)
- Dependências: R4.1
- Custo: ztunnel por nó e istiod; entra na conta da R4.7
- Entregáveis:
  - EKS e AKS com os charts upstream do ambient (o add-on gerenciado do AKS usa sidecars); conferir a
    compatibilidade do istio-cni com o VPC CNI e o Azure CNI Overlay.
  - GKE Autopilot: verificar se o ambient (istio-cni e ztunnel, que pedem privilégios) é aceito; se
    não for, documentar e manter a malha desligada no Autopilot.
- Aceite:
  - Render e kubeconform do perfil `full`; a resposta sobre o Autopilot registrada no
    `docs/ARQUITETURA.md` do tx03v2.

### R4.4 Argo CD na nuvem e deploy do app por GitOps

- Status: `pendente`
- Repos: tx01v2, tx02v2, tx03v2, dx01v2, dx02v2, dx03v2
- Origem: v1 implementado em parte (Argo CD instalado por workflow; a Application do GCP apontava para um caminho que não existia)
- Dependências: R4.1
- Custo: nenhum além dos recursos do Argo CD
- Entregáveis:
  - Argo CD sem usuário admin, com ClusterIP, app-of-apps da plataforma a partir do repositório tx e
    uma Application do app a partir do repositório dx (público, por https, sem credencial).
  - O workflow de deploy dos dx passa de push (`deploy-<nuvem>.sh` aplicando manifests) para commit e
    sync, com o push mantido como alternativa documentada.
- Aceite:
  - Render e validação das Applications; o mesmo fluxo que o lab local prova (commit, sync,
    self-heal); `não executado em nuvem (v2)`.

### R4.5 Velero com o object storage de cada nuvem

- Status: `pendente`
- Repos: tx01v2, tx02v2, tx03v2
- Origem: v1 implementado de outro jeito (backups por workflows: AWS Backup, backups do Azure SQL e do Cloud SQL; sem Velero)
- Dependências: R4.1
- Custo: armazenamento dos backups (centavos por rodada) e as requisições
- Entregáveis:
  - Bucket ou container com criptografia e ciclo de vida no `terraform/envs/lab`; plugin da AWS (S3 +
    Pod Identity), da Azure (Blob + Workload ID) e do Google Cloud (Cloud Storage + Workload Identity
    Federation).
  - O drill de restore do lab local descrito no RUNBOOK para a rodada de quem fizer fork.
- Aceite:
  - `terraform test` do bucket e das permissões; `não executado em nuvem (v2)`.

### R4.6 Gatekeeper, Trivy Operator e Chaos Mesh na nuvem

- Status: `pendente`
- Repos: tx01v2, tx02v2, tx03v2
- Origem: v1 implementado (Gatekeeper e Trivy Operator instalados por workflow; Chaos Mesh no AKS)
- Dependências: R4.1
- Custo: recursos dos componentes (R4.7)
- Entregáveis:
  - Namespaces isentos por nuvem (os do sistema de cada provedor), as mesmas constraints do lab local
    e a suíte do gator.
  - Restrições do GKE Autopilot (sem pods privilegiados): o que do Chaos Mesh roda lá e o que fica só
    no lab local, documentado.
- Aceite:
  - Render, kubeconform e gator verdes para as três nuvens.

### R4.7 Dimensionamento e custo do perfil `full`

- Status: `pendente`
- Repos: tx01v2, tx02v2, tx03v2
- Origem: dívida v2
- Dependências: R4.1, R4.2
- Custo: é o que o item mede
- Entregáveis:
  - A soma dos requests do perfil `full` por nuvem e o tamanho ou número de nós que cabe;
    `docs/CUSTOS.md` com o custo por hora do perfil `full` e o budget ajustado.
- Aceite:
  - Uma tabela por nuvem com os requests somados e o custo; o padrão continua o perfil `core`.

### R4.8 Do fork à própria nuvem, de ponta a ponta

- Status: `pendente`
- Repos: tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: dívida v2 (a definição de pronto da DEC-11)
- Dependências: R4.1, R4.4, R4.5, R4.6, R4.7
- Custo: nenhum aqui; quem faz fork paga a própria rodada (`docs/CUSTOS.md`)
- Entregáveis:
  - O `FORK.md` e o `docs/RUNBOOK.md` de cada par com o caminho inteiro na conta de quem faz fork:
    bootstrap, apply, plataforma (`core` ou `full`), deploy do app por GitOps, smoke, destroy e
    checagem de sobras, com o custo por hora de cada perfil e o que fazer quando um passo falha.
- Aceite:
  - O check de links e o harness de cada repositório confirmam que todo script, alvo do `make`,
    workflow e variável citados nesse caminho existem; `não executado em nuvem (v2)`.

## S. Sustentação e calendário

Itens com data. As rotinas (CI semanal, Dependabot mensal, revisão trimestral) estão no
[docs/SUSTENTACAO.md](docs/SUSTENTACAO.md) deste repositório e no de cada repositório da família.

### S.1 Node.js 26 LTS nos apps

- Status: `pendente`
- Repos: dx01v2, dx02v2, dx03v2
- Origem: dívida v2 (calendário)
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - O Node.js 26 vira LTS em 2026-10-28; o 24 vai até 2028-04-30. Na primeira revisão trimestral
    depois de 2026-10-28: `.nvmrc`, `engines`, imagens `node` de build e distroless `nodejs26`
    (quando existirem), devcontainer e `@types/node`, nos três dx na mesma rodada.
- Aceite:
  - CI verde nos três e o `family-app` igual (mesmos `engines`).

### S.2 Kubernetes 1.37 na família e kubectl alinhado

- Status: `pendente`
- Repos: tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: dívida v2 (calendário)
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - Prazos da 1.36: AKS até 2027-06-30, GKE por volta de 2027-06-30, EKS com suporte padrão até
    2027-08-02. A 1.37 já existe no EKS (2026-10-01) e no AKS (outubro de 2026).
  - Nó do kind, schemas do kubeconform e padrões do EKS, do AKS e da GKE na 1.37, depois de conferir os
    controladores (AWS Load Balancer Controller, ALB Controller da Azure, ESO).
  - O kubectl igual nos seis (hoje 1.37.1 nos tx e 1.36.5 nos dx); a exceção do `family-versions` sai
    na mesma rodada.
- Aceite:
  - CI verde nos seis e o `family-versions` sem exceção.

### S.3 Istio 1.31 para 1.33

- Status: `pendente`
- Repos: tx01v2, tx02v2, tx03v2, dx01v2, dx02v2, dx03v2
- Origem: dívida v2 (calendário)
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - O Istio 1.31 sai de suporte por volta de 2027-02 (seis semanas depois da 1.33). Charts (base,
    istiod, cni, ztunnel) com SHA256, digests das imagens e as NetworkPolicies dos dx se alguma porta
    mudar.
- Aceite:
  - `e2e` e `e2e-platform` verdes nos seis; `family-versions` e `family-digests` verdes.

### S.4 Exceções do trivy que vencem em 2027-04-30

- Status: `pendente`
- Repos: tx01v2, tx02v2
- Origem: dívida v2 (calendário)
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - tx01v2: `AWS-0040`, `AWS-0041`, `AWS-0132` e `KSV-0056`; tx02v2: `AZU-0012` e `AZU-0013`. Cada uma é
    corrigida ou renovada com `statement` novo e no máximo uns 7 meses de validade, antes de abril de
    2027.
- Aceite:
  - O check `trivyignore-policy` verde depois de 2027-04-30.

### S.5 nginx 1.32 nos apps

- Status: `pendente`
- Repos: dx01v2, dx02v2, dx03v2
- Origem: dívida v2 (calendário)
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - A linha estável do nginx muda para a 1.32 por volta de abril de 2027: `nginx-unprivileged` de
    `1.30-alpine-slim` para `1.32-alpine-slim`, por digest, nos três dx.
- Aceite:
  - O gate do trivy nas imagens verde e o `family-digests` igual nos três.

### S.6 Amazon Linux 2023 nos nós do EKS

- Status: `pendente`
- Repos: tx01v2
- Origem: dívida v2 (calendário)
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - O AL2023 tem suporte padrão até 2027-06-30 e manutenção até 2029-06-30; antes de meados de 2027,
    conferir o tipo de AMI do node group e o sucessor recomendado para o EKS.
- Aceite:
  - Decisão registrada no `docs/SUSTENTACAO.md` do tx01v2 e `terraform test` do node group verde.

### S.7 Schemas de CRD do kubeconform

- Status: `pendente`
- Repos: tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: dívida v2
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - Os tx fixam o datreeio/CRDs-catalog em `f3e4382` (2026-06-02), porque a revisão `b7e2015` quebrou
    o schema `external-secrets.io/clustersecretstore_v1`; os dx fixam `63669a5` (2026-10-08). A cada
    revisão trimestral, conferir se o catálogo foi corrigido e alinhar os seis no mesmo commit.
- Aceite:
  - `kubeconform` verde nos seis com o mesmo commit do catálogo.

### S.8 Menções a "contract v1" que descrevem a versão 2

- Status: `feito`
- Repos: tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: dívida v2 (o contrato passou para a versão 2 na R1; cerca de cem comentários, mensagens dos scripts de deploy e linhas de docs ainda dizem "contract v1")
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - Trocar por "contrato" sem versão onde o texto vale para qualquer versão, ou por "v2" onde a versão
    importa, sem mudar comportamento; um PR por repositório.
- Aceite:
  - `git grep -i "contract v1"` só acha o histórico (CHANGELOG e notas datadas).
- Evidência: [tx01v2#12](https://github.com/maringelix/tx01v2/pull/12), [tx02v2#10](https://github.com/maringelix/tx02v2/pull/10), [tx03v2#9](https://github.com/maringelix/tx03v2/pull/9), [dx01v2#12](https://github.com/maringelix/dx01v2/pull/12), [dx02v2#8](https://github.com/maringelix/dx02v2/pull/8), [dx03v2#10](https://github.com/maringelix/dx03v2/pull/10)

### S.9 Primeira revisão trimestral conjunta da família

- Status: `pendente`
- Repos: tx00v2, tx01v2, dx01v2, tx02v2, dx02v2, tx03v2, dx03v2
- Origem: dívida v2 (rotina de cada `docs/SUSTENTACAO.md`)
- Dependências: nenhuma
- Custo: nenhum
- Entregáveis:
  - Em janeiro de 2027, nos sete: ferramentas do harness (terraform, tflint e rulesets, trivy,
    actionlint, shellcheck, kubeconform, gitleaks, kubectl, helm, kind, gator, hadolint, promtool,
    kubelogin, gcloud, jq), charts e digests, schemas, preços dos `docs/CUSTOS.md` e o calendário.
- Aceite:
  - Um PR por repositório com o CI verde e o `make family` verde no fim.

## Mapa v1 → v2

Fontes do lado v1: os READMEs, os workflows, o `IMPLEMENTATION_STATUS` do tx01 e as auditorias dos
repositórios v1 (privados e arquivados; por isso não há links). "Feito" na coluna da v2 quer dizer
`verificado no CI` no lab local, salvo quando a linha diz que é só código.

| Capacidade | v1 | v2 hoje | Item |
|---|---|---|---|
| Terraform com módulos e state remoto | implementado nas três nuvens | bootstrap e `terraform/envs/lab` nos três tx, com `terraform test` e provider mockado (código) | código; rodadas reais fora do escopo (DEC-11) |
| Testes e lint de IaC | só no tx01 | fmt, validate, lock files, tflint com ruleset, trivy e `terraform test` nos três tx | feito (R0.1) |
| Kubernetes gerenciado | EKS 1.32, AKS, GKE Autopilot | EKS, AKS e GKE Autopilot 1.36 (código); kind 1.36 no lab local | S.2 |
| Modo EC2/VM | implementado (EC2 com deploy por SSM; VM na Azure) | descartado (DEC-2) | nenhum |
| Banco | RDS PostgreSQL, Azure SQL, Cloud SQL PostgreSQL | PostgreSQL 17 nas três (Azure SQL não portado, DEC-3); local só com TLS | nenhum |
| Registry | ECR, ACR, Artifact Registry | os três (código) e o gêmeo local | código |
| Entrada e load balancer | ALB só HTTP, ingress-nginx no AKS, Ingress do GCE | ALB com o Load Balancer Controller, AGC com Gateway API, Gateway da GKE (código); Istio Gateway local | código |
| WAF da AWS | rate limit, Common, SQLi, KnownBadInputs | Common, KnownBadInputs, SQLi, IpReputation e rate limit por IP (código) | fora do escopo (DEC-11) |
| WAF da Azure | opção de workflow (parcial) | AGC com DRS 2.1 e Bot Manager 1.1 em Prevention (código) | fora do escopo (DEC-11) |
| Cloud Armor | sete regras pré-configuradas, rate limit, Adaptive Protection | sqli e xss (código) | fora do escopo (DEC-11) |
| TLS | Let's Encrypt no AKS, certificado gerenciado no GKE, AWS só HTTP | cert-manager com a CA do lab local; overlay `aws-https` com ACM | fora do escopo (DEC-11) |
| Service mesh | Istio no AKS e no GKE, mTLS `PERMISSIVE`, retries, timeouts, outlier, canário | Istio ambient local com mTLS `STRICT` e `AuthorizationPolicy` por identidade | R4.3 |
| GitOps | Argo CD instalado por workflow, Application quebrada no GCP | Argo CD local com commit, sync e self-heal; deploy do app por GitOps | R4.4 |
| Prometheus e Grafana | instalados por workflow nas três nuvens | local, com ServiceMonitor, regras testadas com promtool e dashboard como código | R4.1, R4.2 |
| Logs | Loki na AWS, Log Analytics na Azure | Loki + Alloy local | R4.1, R4.2 |
| Alertas no Slack | implementado | local, com o payload validado no CI | feito (R1.2) |
| Tracing e APM | Application Insights e o Jaeger do Istio (parcial) | OpenTelemetry e Tempo locais; exportadores para X-Ray, Application Insights e Cloud Trace (código) | feito (R1.1, R1.4, R1.6) |
| Trivy | imagens no CI | trivy config, gate de imagem no CI e Trivy Operator local | feito (R0.1, R0.3) |
| tfsec, Checkov e gitleaks | no tx02 | trivy config (no lugar do tfsec) e gitleaks nos sete | feito (R0.1) |
| OWASP ZAP | baseline no tx02 | ainda não | fora do escopo (DEC-11) |
| SonarCloud ou SonarQube | só citado no dx03 | ainda não (SonarQube Community Build, DEC-1) | fora do escopo (DEC-11) |
| CodeQL | ausente (só upload de SARIF) | ainda não | fora do escopo (DEC-11) |
| Dependabot | planejado | mensal e agrupado nos sete | feito (R0.1) |
| Gatekeeper | implementado | local em `deny`, com a suíte do gator | feito (R0.3), R4.6 |
| NetworkPolicy e PDB | parcial | aplicados no kind e conferidos no harness | feito (R0.1) |
| Backup | workflows manuais (AWS Backup, Azure SQL, Cloud SQL), sem Velero | Velero local com restore; backups gerenciados dos bancos (código) | R4.5 |
| Chaos | Chaos Mesh manual no tx02: pod, rede, CPU, memória, desligamento de nó | local com hipóteses: pod kill, latência, stress, latência no banco | feito (R0.3, R1.3); falha de nó fora do escopo (DEC-11) |
| DR multirregião | planejado (tudo numa região) | ainda não | fora do escopo (DEC-11) |
| FinOps | budget no GCP, escala por workflow, sem OpenCost | budgets nos bootstraps, `docs/CUSTOS.md` por par, Spot no EKS | fora do escopo (DEC-11) |
| Autoscaling | HPA; nós no AKS e no Autopilot; sem Cluster Autoscaler nem Karpenter | HPA 2–4 local; AKS 1–3 e Autopilot (código) | fora do escopo (DEC-11) |
| CI com OIDC | implementado | OIDC e Workload Identity Federation com `sub` exatos e testados | feito (R0.1) |
| Segredos | parcial (Secrets do Kubernetes) | ESO com Secrets Manager, Key Vault e Secret Manager (código) e local | feito (R0.3) |
| Várias nuvens | pilhas paralelas, sem failover | três pares e o hub com os checks de coerência | feito (R0.6) |
| Teste de carga | planejado (auditoria) | ainda não | fora do escopo (DEC-11) |
| Assinatura de imagem e Binary Authorization | planejado (auditorias) | ainda não | fora do escopo (DEC-11) |

## Decisões registradas

| ID | Data | Quem | Decisão |
|---|---|---|---|
| DEC-1 | 2026-10-14 | Bruno | SonarQube Community Build num container do harness, sem SonarCloud (sem conta, funciona em forks) |
| DEC-2 | 2026-10-14 | Bruno | Sem modo EC2/VM na v2 |
| DEC-3 | 2026-10-14 | Bruno | PostgreSQL em todos os pares; o Azure SQL do v1 não é portado (o mesmo app nas três nuvens) |
| DEC-4 | 2026-10-14 | Bruno | A ordem das rodadas é livre; tudo local primeiro, a nuvem como código |
| DEC-5 | 2026-10-11 | lab | O mesmo app (dx01v2, commit `22e69c4`) nos três dx; só o alvo de deploy muda |
| DEC-6 | 2026-10-14 | R1 | Application Insights sempre ligado no tx02v2, para manter "papéis atribuídos = lista do ABAC" |
| DEC-7 | 2026-10-14 | R1 | Spans manuais no app, sem auto-instrumentação (que pediria um loader de ESM) |
| DEC-8 | 2026-10-14 | R1 | Tempo pelo chart `grafana-community/tempo` 3.1.0; o `grafana/tempo` 1.24.4 está depreciado |
| DEC-9 | 2026-10-14 | hub | No tx00v2 só o `static` é obrigatório; o `family` é informativo porque depende de seis outros repositórios |
| DEC-10 | 2026-10-13 | lab | O lab local reconstrói a plataforma do v1 no Docker: ninguém precisa de conta de nuvem para aprender |
| DEC-11 | 2026-10-15 | Bruno | Escopo: o lab fica pronto para fork, validado no Docker e no CI; nada é homologado numa nuvem real. Saem as rodadas reais, o ensaio de fork com outra conta, DR, FinOps, HTTPS nas nuvens, os extras de segurança e qualidade e as propostas |
| DEC-12 | 2026-10-15 | Bruno | O tamanho `small` do lab local fica em 7 GB de Docker; a meta da R1.8 era 6 GB, onde a sonda de rollout perde requisições |

As decisões pendentes DP-1 a DP-5 (domínio, orçamento, segunda conta do GitHub, propostas e DR na
nuvem) caíram com a DEC-11.

## Riscos e limites conhecidos

- Memória: o perfil `full` pede 8 GB de Docker; com `LOCAL_SIZE=small`, a plataforma com o app cabe em
  7 GB (R1.8). O apiserver, com os CRDs da plataforma inteira, passa de 1 GiB sozinho. Rodadas pesadas
  ficam no CI, nunca na máquina de desenvolvimento.
- Tempo de CI: os jobs `e2e` levam de 12 a 15 minutos; o GitHub Actions não cobra repositórios
  públicos, mas limita os jobs simultâneos.
- Nuvem: nada da v2 rodou numa nuvem, e isso não vai mudar aqui (DEC-11). Os números de custo são
  preços de lista de outubro de 2026, sem impostos e sem transferência de dados; a primeira rodada de
  quem fizer fork pode achar erros que os testes com provider mockado não pegam.
- O hub aponta drift, não impede: o `family` é informativo e roda nos PRs do hub, em todo push na
  `main` e toda segunda-feira.
- Upstream: um catálogo de schemas quebrado, um chart removido ou uma CVE sem correção numa imagem
  base pode travar um check. A regra é parar, fixar com data e relatar, nunca enfraquecer o check.
- Fork: o `FORK.md` não foi ensaiado com outra conta (fora do escopo). Os scripts só agem no que o
  lab criou (R0.7), mas os papéis de CI ainda pressupõem uma conta, assinatura ou projeto dedicados
  ao lab (R3.16) e o environment `lab` protegido (R3.15).

## Como atualizar este roadmap

1. Ao abrir os PRs de um item, mude o status para `em andamento`, aqui e na visão geral.
2. Quando todos os repositórios do item mesclarem, mude para `feito`, preencha `Evidência` com os
   links dos PRs e registre a rodada no [docs/HISTORICO.md](docs/HISTORICO.md) e no `CHANGELOG.md`.
3. Item novo: use o formulário "Roadmap item" das issues; um ID nunca é reaproveitado.
4. Antes do push: `make static` (o check `roadmap`) e `make family` (o `family-evidence` confere os
   PRs dos itens `feito`).
