# Histórico da família v2

O que foi feito, em ordem, com os pull requests mesclados (datas de merge em UTC). O check
`family-evidence` confere que todo PR citado aqui está na `main` do repositório. O que ainda falta
está no [ROADMAP.md](../ROADMAP.md).

## Antes da v2

O lab v1 (repositórios `tx01` a `tx03` e `dx01` a `dx03`, mais o `tx00` de auditorias) rodou na AWS,
na Azure e no Google Cloud enquanto havia créditos, com a plataforma instalada por workflows manuais.
As lições de lá estão no `docs/LICOES_APRENDIDAS.md` de cada repositório de infraestrutura da v2. Os
repositórios v1 são privados e foram arquivados em 2026-10-12; a v2 não depende deles.

## 2026-10-10 a 2026-10-12: os seis repositórios (R0.1, R0.2)

- AWS: o `tx01v2` e o `dx01v2` nasceram com o harness, o CI, os guardrails e os docs; o primeiro CI
  verde virou os rótulos para `verificado no CI`:
  [tx01v2#1](https://github.com/maringelix/tx01v2/pull/1),
  [dx01v2#3](https://github.com/maringelix/dx01v2/pull/3) (também as faixas do Dependabot).
- Azure: o `tx02v2` e o `dx02v2`, portes do par da AWS com o que a Azure exige:
  [tx02v2#1](https://github.com/maringelix/tx02v2/pull/1),
  [dx02v2#1](https://github.com/maringelix/dx02v2/pull/1); a tabela da família e a regra de paridade
  do app no par da AWS: [tx01v2#2](https://github.com/maringelix/tx01v2/pull/2),
  [dx01v2#4](https://github.com/maringelix/dx01v2/pull/4).
- Google Cloud: o `tx03v2` e o `dx03v2`:
  [tx03v2#1](https://github.com/maringelix/tx03v2/pull/1),
  [tx03v2#2](https://github.com/maringelix/tx03v2/pull/2),
  [dx03v2#3](https://github.com/maringelix/dx03v2/pull/3); a tabela da família ganhou o par do Google
  Cloud ([tx01v2#3](https://github.com/maringelix/tx01v2/pull/3),
  [tx02v2#2](https://github.com/maringelix/tx02v2/pull/2)), e os outros apps receberam o caso de teste
  do `X-Forwarded-For` do load balancer do Google, com as majors do Node ignoradas no Dependabot
  ([dx01v2#5](https://github.com/maringelix/dx01v2/pull/5),
  [dx02v2#2](https://github.com/maringelix/dx02v2/pull/2),
  [dx03v2#4](https://github.com/maringelix/dx03v2/pull/4)).
- Os seis ficaram públicos com o `scripts/repo-guardrails.sh` aplicado, e os repositórios v1 foram
  arquivados.

## 2026-10-13: o lab local com a plataforma completa do v1 (R0.3)

Kind com os gêmeos locais da nuvem e a plataforma do v1 inteira (Istio ambient, cert-manager, ESO,
Prometheus, Alertmanager, Grafana, Loki, Argo CD, Gatekeeper, Trivy Operator, Velero, Chaos Mesh),
provada por sondas, e o app em cima dela por GitOps:

- [tx01v2#5](https://github.com/maringelix/tx01v2/pull/5) e
  [tx01v2#6](https://github.com/maringelix/tx01v2/pull/6) (a desmontagem ignora um Service de
  Gateway que já sumiu), [tx02v2#3](https://github.com/maringelix/tx02v2/pull/3),
  [tx02v2#4](https://github.com/maringelix/tx02v2/pull/4),
  [tx03v2#3](https://github.com/maringelix/tx03v2/pull/3).
- [dx01v2#6](https://github.com/maringelix/dx01v2/pull/6),
  [dx02v2#3](https://github.com/maringelix/dx02v2/pull/3),
  [dx03v2#5](https://github.com/maringelix/dx03v2/pull/5).

## 2026-10-14: o lab local como gate de merge e pronto para fork (R0.4, R0.5)

- Os jobs `e2e` e `e2e-platform` entraram nos rulesets:
  [tx01v2#7](https://github.com/maringelix/tx01v2/pull/7),
  [dx01v2#7](https://github.com/maringelix/dx01v2/pull/7),
  [tx02v2#5](https://github.com/maringelix/tx02v2/pull/5),
  [dx02v2#4](https://github.com/maringelix/dx02v2/pull/4),
  [tx03v2#4](https://github.com/maringelix/tx03v2/pull/4),
  [dx03v2#6](https://github.com/maringelix/dx03v2/pull/6).
- `FORK.md`, bootstrap sem dono padrão, `repo-guardrails.sh` pronto para forks e o e2e-platform
  clonando o tx configurado: [tx01v2#8](https://github.com/maringelix/tx01v2/pull/8),
  [dx01v2#8](https://github.com/maringelix/dx01v2/pull/8),
  [tx02v2#6](https://github.com/maringelix/tx02v2/pull/6),
  [dx02v2#5](https://github.com/maringelix/dx02v2/pull/5),
  [tx03v2#5](https://github.com/maringelix/tx03v2/pull/5),
  [dx03v2#7](https://github.com/maringelix/dx03v2/pull/7).

## 2026-10-14: rodada 1, observabilidade 2.0, alertas, chaos e rollout (R1)

Contrato v2 nos três pares (a chave nova é o endpoint OTLP do Collector).

- Infraestrutura: OpenTelemetry Collector e Tempo no lab local, spans do Istio Gateway, spanmetrics
  com exemplars, Grafana ligando logs, métricas e traces, receiver do Slack, chaos de latência e
  stress, e os exportadores de nuvem (X-Ray, Application Insights, Cloud Trace) como código:
  [tx01v2#9](https://github.com/maringelix/tx01v2/pull/9),
  [tx02v2#7](https://github.com/maringelix/tx02v2/pull/7),
  [tx03v2#6](https://github.com/maringelix/tx03v2/pull/6).
- App: spans manuais na API, `trace_id` nos logs, exemplars, rollout sem downtime e latência entre a
  API e o banco: [dx01v2#9](https://github.com/maringelix/dx01v2/pull/9),
  [dx02v2#6](https://github.com/maringelix/dx02v2/pull/6),
  [dx03v2#8](https://github.com/maringelix/dx03v2/pull/8).
- O que o CI achou e o lab local não: o exemplar do spanmetrics vive um flush de 15 s, então o
  ServiceMonitor passou a 10 s; o Gateway fala com o Collector por HBONE (15008), porque o Collector
  está na malha; uma instalação do servidor do Trivy Operator falhou uma vez (R1.9); no dx03v2, a
  lista exata de NetworkPolicies do overlay `gcp` no `check-manifests.mjs` não tinha a política nova
  para o Collector. Localmente, o webhook do ESO do tx03v2 deu timeout duas vezes, e o CI passou
  (R1.10).

## 2026-10-14: o hub (R0.6)

Este repositório: README com as referências, o roadmap detalhado do que falta para o lab completo
nas três nuvens, os guardrails da família e o harness com os checks entre os repositórios.

- A linha do hub na tabela da família dos seis READMEs: nos PRs da rodada 1 do tx03v2, do dx02v2 e
  do dx03v2 e em PRs de documentação nos outros:
  [tx01v2#10](https://github.com/maringelix/tx01v2/pull/10),
  [dx01v2#10](https://github.com/maringelix/dx01v2/pull/10) (também um comentário desatualizado do
  `check-manifests.mjs`), [tx02v2#8](https://github.com/maringelix/tx02v2/pull/8).
- Docs que ainda diziam que a rodada de ponta a ponta do lab local era `planejado`, achados ao
  escrever o roadmap: no tx02v2#8 e em [tx03v2#7](https://github.com/maringelix/tx03v2/pull/7).
- Ao montar os checks da família, todos os invariantes valeram nos seis repositórios, menos um que
  virou exceção registrada: o kubectl é 1.37.1 nos tx e 1.36.5 nos dx (item S.2 do roadmap).
