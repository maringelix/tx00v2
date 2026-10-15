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
- O primeiro CI do hub passou (`static` 9 de 9, `family` 11 de 11 contra a `main` dos seis), e o
  `scripts/repo-guardrails.sh` aplicou o ruleset (`static` obrigatório), o secret scanning com push
  protection, o reporte privado de vulnerabilidades e a aprovação de runs de forks, lidos de volta com
  `gh api`.

## 2026-10-14: scripts que só agem no lab (R0.7)

Uma auditoria só de leitura dos seis repositórios procurou tudo o que poderia quebrar a máquina ou a
nuvem de quem faz fork. Os achados mais graves eram scripts que escolhiam o alvo por uma variável de
ambiente genérica ou pelo contexto atual do kubectl: o `platform/uninstall.sh` apaga todo Ingress,
Gateway e Service `LoadBalancer` do cluster que alcança, e um `CLUSTER_NAME` exportado para outro
cluster o levaria até lá. Os testes de integração dos apps apagam tabelas no banco de `DB_*`, e o
RUNBOOK de desenvolvimento exportava o banco de desenvolvimento.

- Infraestrutura: [tx01v2#11](https://github.com/maringelix/tx01v2/pull/11),
  [tx02v2#9](https://github.com/maringelix/tx02v2/pull/9),
  [tx03v2#8](https://github.com/maringelix/tx03v2/pull/8).
- Apps: [dx01v2#11](https://github.com/maringelix/dx01v2/pull/11),
  [dx02v2#7](https://github.com/maringelix/dx02v2/pull/7),
  [dx03v2#9](https://github.com/maringelix/dx03v2/pull/9).
- O que a validação achou antes dos PRs: o check novo `policy-scripts` acusava a própria linha do
  `grep` no harness, e o teste do output de kubeconfig do tx01v2 ainda esperava o comando antigo. No
  Google Cloud, o schema do provider fixado confirmou que o cluster recebe o label `project` pelos
  `default_labels` (`terraform_labels`), a condição para a trava não recusar o próprio lab.
- O resto da auditoria virou os itens R3.13 a R3.18.

## 2026-10-15: rodada de dívidas (R1.7, R1.10, S.8)

- R1.7: o `platform/install.sh` do tx01v2 instala o Collector a partir do arquivo do chart conferido
  contra o `OTEL_COLLECTOR_CHART_SHA256`, agora em `platform/versions.env` como no tx02v2 e no tx03v2
  (antes, a nuvem pegava o chart do repositório sem conferir): [tx01v2#12](https://github.com/maringelix/tx01v2/pull/12).
- R1.10: o webhook do External Secrets do lab local do tx03v2 herdava os limites de CPU do Autopilot
  (50m), porque o Helm mescla os dois arquivos de values. Os values locais tiram os `resources` do
  webhook e do cert controller e dão ao controller um teto de 1 CPU (um `null` aninhado que o chart
  não tem como padrão sai como `cpu: null` no manifest). Três rodadas locais seguidas do perfil
  `observability` passaram, com 22 de 22 sondas cada, num Docker Desktop de 7,65 GiB:
  [tx03v2#9](https://github.com/maringelix/tx03v2/pull/9).
- S.8: cerca de 150 menções a "contract v1" viraram "the contract" ou `docs/CONTRATO.md`, ou "v2" onde
  a versão importa (o HTTPS fica fora do contrato v2). Ficaram de propósito os CHANGELOGs, a nota datada
  do `docs/CONTRATO.md` do dx02v2 e as linhas de troubleshooting dos RUNBOOKs dos dx sobre uma
  plataforma antiga ainda no contrato v1: [tx01v2#12](https://github.com/maringelix/tx01v2/pull/12), [tx02v2#10](https://github.com/maringelix/tx02v2/pull/10), [tx03v2#9](https://github.com/maringelix/tx03v2/pull/9),
  [dx01v2#12](https://github.com/maringelix/dx01v2/pull/12), [dx02v2#8](https://github.com/maringelix/dx02v2/pull/8), [dx03v2#10](https://github.com/maringelix/dx03v2/pull/10).
- R1.9 continua pendente: a falha do servidor do Trivy aconteceu uma vez (2026-10-14, antes do
  diagnóstico de instalação existir) e não voltou; o aceite pede dez rodadas verdes seguidas nos três
  tx, e o tx01v2 está em 8.
- O que a validação achou antes dos PRs: o `prettier` do dx03v2 quebrou uma linha que passou de 120
  colunas com a mensagem nova, e o primeiro jeito de tirar o limite de CPU do controller (`null`)
  renderizava `cpu: null`.

## 2026-10-15: tamanho `small` do lab local (R1.8)

- O que foi feito: `LOCAL_SIZE=small` nos três tx põe `platform/local/values/small/<chart>.yaml` por
  último no `helm_install` (limites menores com `GOMEMLIMIT`, retenção curta no Prometheus e no Tempo,
  sem as séries de cAdvisor e os histogramas do apiserver, menos workers no Argo CD, um scan do Trivy
  por vez, auditoria do Gatekeeper só dos tipos das constraints) e acrescenta
  `terraform/envs/local/kind-config-small.yaml` à config do kind (`GOMEMLIMIT` no apiserver, no
  controller-manager e no etcd). Os dx ganharam o job `e2e-platform-small` (Docker-in-Docker sem swap):
  [tx01v2#13](https://github.com/maringelix/tx01v2/pull/13), [dx01v2#13](https://github.com/maringelix/dx01v2/pull/13), [tx02v2#11](https://github.com/maringelix/tx02v2/pull/11), [dx02v2#9](https://github.com/maringelix/dx02v2/pull/9), [tx03v2#10](https://github.com/maringelix/tx03v2/pull/10), [dx03v2#11](https://github.com/maringelix/dx03v2/pull/11).
- Como foi medido: a primeira tentativa rodou o lab inteiro num Docker-in-Docker de 6 a 7 GB na
  máquina de desenvolvimento (i5, 16 GB) e travou o Windows. Desde então, rodadas pesadas só no GitHub
  Actions. Aquela rodada local mostrou o tamanho padrão falhando em 7 GB (thrashing). No CI, o `small`
  falhou em 6 GB na primeira versão (memória anônima de 4,63 GiB, o app nunca ficou saudável) e, com o
  plano de controle e o Gatekeeper ajustados, em 6 GB passaram 14 de 18 sondas, e em 7 GB e em 8 GB,
  todas.
- A decisão: a meta era 6 GB; o Bruno escolheu 7 GB, abaixo dos 7,65 GiB do Docker Desktop de
  desenvolvimento. Ir a 6 GB pedia mexer no que o lab é (auditoria do Gatekeeper, watch cache do
  apiserver), por 1 GB.
- O que a validação achou: o `GOMEMLIMIT` não segurou o apiserver (1,2 GiB com os CRDs da plataforma);
  em duas das nove rodadas em 7 GB o kernel matou a cópia do plugin do Velero na instalação, um init
  container sem requests que o kubelet roda de novo, e o job passou a reportar OOM kills em vez de
  falhar por eles (as sondas são o portão). O shellcheck pegou duas construções do script novo (crase
  num `printf` e um `sed` trocável por `printf`).
- R1.9 fechou junto: com as rodadas desta rodada, o job `e2e` chegou a 11 verdes seguidas no tx01v2,
  20 no tx02v2 e 18 no tx03v2, e a falha do servidor do Trivy não voltou.

## 2026-10-15: escopo novo, pronto para fork (DEC-11)

- O roadmap somava umas 19 rodadas e cerca de 100 PRs, porque juntava rodadas reais nas nuvens, DR,
  FinOps, extras de segurança e qualidade e propostas além do v1. O Bruno definiu o que é pronto: quem
  fizer fork roda o lab no Docker e nas próprias nuvens, e nada é homologado numa nuvem real.
- Ficaram duas rodadas: R3 (segurança para quem faz fork: R3.10 e R3.13 a R3.18) e R4 (a plataforma
  completa na nuvem como código, mais o R4.8, o caminho do fork até a própria nuvem). O resto saiu do
  roadmap; os textos completos ficam no `ROADMAP.md` do commit `736bbb7`.
- O DR local também saiu (pergunta direta ao Bruno): ficou de fora para fechar o lab em duas rodadas.
