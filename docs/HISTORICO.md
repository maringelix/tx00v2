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

## 2026-10-15 e 2026-10-16: a rodada R3, segurança para quem faz fork

- Um PR por repositório, o tx antes do dx: [tx01v2#14](https://github.com/maringelix/tx01v2/pull/14) (R3.10, R3.14 a R3.18), [dx01v2#14](https://github.com/maringelix/dx01v2/pull/14), [tx02v2#12](https://github.com/maringelix/tx02v2/pull/12) (R3.13 a R3.18), [dx02v2#10](https://github.com/maringelix/dx02v2/pull/10), [tx03v2#11](https://github.com/maringelix/tx03v2/pull/11) (R3.13 a R3.18) e [dx03v2#12](https://github.com/maringelix/dx03v2/pull/12) (R3.15, R3.17, R3.18), mais [dx01v2#15](https://github.com/maringelix/dx01v2/pull/15), que acertou o pin do dx01v2 no commit mesclado do tx01v2. Em 2026-10-16, [tx03v2#12](https://github.com/maringelix/tx03v2/pull/12) fechou o R3.16 do Google Cloud.
- O que a rodada mudou: o `sub` imutável do GitHub nas identidades de CI das três nuvens (a mesma confiança que um fork novo emite), o `repo-guardrails.sh` que falha em vez de pular, a permission boundary da AWS, os papéis de plan mais estreitos, as listas de pessoas e endereços em secrets mascarados, o `destroy.sh` que sempre chega ao fim, o `leftovers.sh` que só culpa o que é do lab, o pre-flight do lab local e o apply do Google Cloud sem Editor.
- O que o CI achou e a rodada corrigiu: avisos do ShellCheck (uma expansão sem aspas no `local-lab.sh`, uma função só chamada por `trap` num teste e um contador de loop nos scripts de deploy local dos dx), os padrões do pre-flight local copiados do tx01v2 para o tx02v2 e o tx03v2 (rede 10.250.0.0/24 e porta 5001 em vez das de cada um), uma corrida no deploy local dos dx (o Deployment ainda com a tag antiga quando a sonda lia), um falso positivo do gitleaks (`generic-api-key` em `...secrets...role_id == "<nome>"` num teste) e um `jq -e` que falhava com uma lista vazia nas máscaras.
- Uma decisão registrada no item: no Google Cloud os papéis do apply não ficam presos aos recursos `tx03v2-lab-*` (R3.16, "Mudado em 2026-10-16"); o projeto dedicado e o pre-flight seguram o que o papel não segura.
- Nada rodou numa nuvem: a prova de cada item é um check do harness, um teste com provider mockado ou um job do CI.

## 2026-10-16: rodada R4, plataforma completa como código e caminho do fork

- Um PR de plataforma por tx, seguido pelo PR de GitOps do dx correspondente: [tx01v2#15](https://github.com/maringelix/tx01v2/pull/15) e [dx01v2#16](https://github.com/maringelix/dx01v2/pull/16), [tx02v2#13](https://github.com/maringelix/tx02v2/pull/13) e [dx02v2#11](https://github.com/maringelix/dx02v2/pull/11), [tx03v2#13](https://github.com/maringelix/tx03v2/pull/13) e [dx03v2#13](https://github.com/maringelix/dx03v2/pull/13). O tx03v2 precisou ainda do PR documental [tx03v2#14](https://github.com/maringelix/tx03v2/pull/14) para alinhar o contrato com a Application e a permissão de refresh do Argo CD. Os dx fixam o commit mesclado do tx do par; os contratos ficaram na v4 (AWS) e v3 (Azure e Google Cloud).
- Os tx agora oferecem perfis `core` e `full` com charts e imagens fixados, overlays por nuvem, Argo CD e app-of-apps, Gatekeeper, Trivy Operator, Velero com armazenamento privado e ciclo de vida de 35 dias, e dimensionamento e custos documentados. O perfil `core` continua padrão. Cada dx publica um commit na branch GitOps da nuvem; o workflow não aceita mudar para push direto. O script local mantém o fallback de push.
- O GKE Autopilot não recebe os componentes que exigem privilégios incompatíveis com o perfil: Istio ambient, node-exporter, Trivy node collector e o daemon privilegiado do Chaos Mesh. O que permanece compatível e o experimento suportado estão registrados no tx03v2.
- O CI validou os renders do perfil `full`, os manifests, os charts GitOps, os testes Terraform com provider mockado, kubeconform, gator, os checks do harness e os e2e locais dos três dx. Nenhuma infraestrutura ou aplicação foi criada numa conta de nuvem; a etiqueta continua `não executado em nuvem (v2)`.
- Uma correção do `policy-workflows` do GCP permite `contents: write` apenas no job protegido de deploy GitOps; as permissões globais permanecem `contents: read`. Nos três dx, o deploy do workflow é sempre GitOps e o push direto fica apenas no script local.
- O `family-digests` encontrou os plugins diferentes de Velero no mesmo caminho de values cloud. A regra agora combina base e overlay como o Helm: exige o mesmo servidor nos três tx e exatamente o plugin do provedor, fixado por versão e digest. Os outros arquivos mantêm a comparação de digests e todas as imagens completas continuam na comparação global por nome e tag.

## 2026-10-16: auditoria do escopo completo e reabertura (DEC-13)

- O Bruno pediu a lista completa de tecnologias e práticas para os três pares. A auditoria
  confrontou Terraform, manifests, workflows, scripts e docs; não executou nenhuma nuvem.
- O fechamento anterior era do escopo reduzido da DEC-11. Permanecem lacunas em DevSecOps,
  promoção de releases, integração cloud, TLS, mesh, dados/HA/DR e FinOps. A
  [auditoria](AUDITORIA_ESCOPO_2026-10-16.md) registra provas e limites por capacidade.
- R7 a R11 passam a conter 11 itens pendentes, agrupados em 22 PRs de construção previstos
  após a revisão do roadmap: 3 + 6 + 6 + 6 + 1. Esta revisão não implementa os recursos;
  homologação cloud e possíveis correções futuras têm estado separado.

## 2026-10-16 a 2026-10-17: R7, DevSecOps e releases

- Três PRs de construção: [dx01v2#17](https://github.com/maringelix/dx01v2/pull/17),
  [dx02v2#12](https://github.com/maringelix/dx02v2/pull/12) e
  [dx03v2#14](https://github.com/maringelix/dx03v2/pull/14).
- SonarQube Community Build descartável com quality gate real e fixture negativa,
  CodeQL/SAST, ZAP, Trivy/gitleaks/cobertura; SBOM, proveniência e assinatura keyless.
  A promoção verifica revisão, checksum e identidade, sem rebuild durante deploy.
- Release local com revisões de conteúdo diferentes, migração expand/contract,
  tráfego contínuo, falha induzida de readiness e rollback para conteúdo conhecido.
  Nenhuma publicação ou implantação numa conta cloud é inferida desses testes.

## 2026-10-17: R8, plataforma integrada nas três clouds

- Seis PRs de construção: [tx01v2#16](https://github.com/maringelix/tx01v2/pull/16),
  [dx01v2#18](https://github.com/maringelix/dx01v2/pull/18),
  [tx02v2#14](https://github.com/maringelix/tx02v2/pull/14),
  [dx02v2#13](https://github.com/maringelix/dx02v2/pull/13),
  [tx03v2#15](https://github.com/maringelix/tx03v2/pull/15) e
  [dx03v2#15](https://github.com/maringelix/dx03v2/pull/15).
- Contratos de DNS/TLS/WAF, caminhos core/full, revisão de IAM e identidade,
  observabilidade do app com retenção, políticas/admissão e scan privado.
  Mesh L7 e Chaos têm exercícios portáveis e limites próprios de cada provedor;
  GKE Autopilot usa mesh gerenciada compatível, sem instalar ambient privilegiado.
- O CI mede canary/retries/outlier, nega identidade indevida, correlaciona sinais
  e testa recuperação. O provedor gerenciado, WAF nativo e TLS público seguem
  sem execução real. Ajustes Azure adicionais
  [tx02v2#15](https://github.com/maringelix/tx02v2/pull/15) e
  [tx02v2#16](https://github.com/maringelix/tx02v2/pull/16) preservaram os gates;
  não são recontados entre os 22 PRs planejados.

## 2026-10-17: R9, continuidade dos dados

- Seis PRs de construção: [tx01v2#17](https://github.com/maringelix/tx01v2/pull/17),
  [dx01v2#19](https://github.com/maringelix/dx01v2/pull/19),
  [tx02v2#17](https://github.com/maringelix/tx02v2/pull/17),
  [dx02v2#14](https://github.com/maringelix/dx02v2/pull/14),
  [tx03v2#16](https://github.com/maringelix/tx03v2/pull/16) e
  [dx03v2#16](https://github.com/maringelix/dx03v2/pull/16).
- HA/PITR/DR opt-in como IaC, runtime e contratos regionais; credenciais atuais
  copiadas por fluxo privado restrito ao destino. AWS usa réplica RDS/ECR e
  backup secundário; Azure usa réplica/ACR, leitura de recuperação e escrow Kopia;
  GCP usa réplica Cloud SQL, backup multirregional e caminho CSI.
- Provas locais reais: backup físico e WAL até ponto conhecido, corrupção recusada,
  bytes originais apagados/PVC novo com checksum, A/B em redes e volumes independentes,
  fencing com primário vivo recusado, perda total, RPO/RTO medidos e failback
  preservando a gravação de B. O CI não executa o failover dos serviços gerenciados.

## 2026-10-17: R10, capacidade e FinOps

- Seis PRs de construção: [tx01v2#18](https://github.com/maringelix/tx01v2/pull/18), [dx01v2#20](https://github.com/maringelix/dx01v2/pull/20), [tx02v2#18](https://github.com/maringelix/tx02v2/pull/18), [dx02v2#15](https://github.com/maringelix/dx02v2/pull/15), [tx03v2#17](https://github.com/maringelix/tx03v2/pull/17), [dx03v2#17](https://github.com/maringelix/dx03v2/pull/17).
- Cluster Autoscaler real no EKS com Pod Identity e tags de descoberta; autoscaler AKS
  e opções Spot/taints/fallback nas três clouds. OpenCost interno, preços regionais
  revisados, serviços externos, owner/ambiente, dashboards, VPA em recomendação e
  gate de estimativa/orçamento/expiração antes de plan/apply. Destroy cloud segue manual.
- Os três TX provaram HPA, PDB, drenagem e custo positivo medido no namespace; os
  três DX provaram SLO pelo Gateway, HPA up/down, requests candidatos antes/depois,
  quota recusando excesso e saturação/recuperação real do pool PostgreSQL.
  Full usa três nós; small preserva um nó/7 GiB e passou separadamente.
- O CI encontrou e corrigiu a ordem de instalação de dependências do teste de labels,
  a leitura assíncrona de alocação e o caminho symlink do cliente montado em ConfigMap.
  O teste de regressão recusa o guard antigo que encerrava sem executar carga.
- Nada rodou numa conta cloud; requests menores e preços simulados não comprovam
  economia de fatura nem escalabilidade/Spot dos serviços gerenciados.

## 2026-10-17: R11, aceite e currículo do escopo completo

- Os 21 PRs de implementação R7–R10 estão mesclados com seus checks aplicáveis verdes.
  O fechamento deste hub completa os 22 PRs planejados pela DEC-13.
- Currículo com 17 aulas, matriz requisito × cloud × implementação × teste × limite
  × rodada/PR, roteiro de homologação futura, READMEs e roadmap reconciliados.
- O registro ENTREGAS.json é conferido por fixtures e por commits mesclados na main.
  Os checks da família incluem os arquivos/pins FinOps, clientes idênticos e CI
  independente sem credenciais cloud do mantenedor. A segunda conta GitHub real
  não foi usada; a prova de execução é em runners limpos do Actions.
- Homologação cloud e sustentação continuam com estados próprios. Não há serviço
  operado 24/7 nem infraestrutura v2 já aprovada numa conta real por este fechamento.
