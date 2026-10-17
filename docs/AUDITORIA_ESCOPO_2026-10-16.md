# Auditoria do escopo completo — 2026-10-16

> Retrato histórico anterior às entregas R7–R11. Consulte o
> [roadmap](../ROADMAP.md) e a [matriz de aceite](ACEITE_FINAL.md) para o estado
> atual e as evidências. As lacunas abaixo descrevem o código auditado naquela data.

## Conclusão e critério

**A construção do escopo completo pedido pelo Bruno ainda não terminou.** R0–R4 entregaram uma
base ampla, com Kubernetes local, aplicação, GitOps, segurança e observabilidade exercitados no
Docker e no CI. O encerramento anterior seguia a DEC-11, que retirara várias capacidades da lista.
A DEC-13 reabre essas capacidades: o novo plano é R7–R11, com **22 PRs de construção planejados**,
além da revisão documental atual. Nenhuma execução da v2 em nuvem está comprovada.

Esta auditoria comparou código, manifests, workflows e limites documentados dos seis labs com o
pedido de 2026-10-16. Foi somente leitura: não repetiu testes nem executou comandos de cloud.
“Implementado” abaixo significa código existente; “verificado em CI” preserva a evidência já
registrada nos repositórios. Docker não prova o comportamento dos controladores gerenciados.
As fontes apontam para `main`; a data identifica o retrato auditado.

## Pedido × prova atual × entrega pendente

| Capacidade pedida | Prova atual e limite | Entrega necessária |
|---|---|---|
| EKS, AKS e GKE Autopilot | Terraform dos três clusters existe. EKS tem grupo Spot e limites de tamanho; isso não instala um controlador de autoscaling. AKS configura autoscaling; GKE habilita Autopilot. [EKS](https://github.com/maringelix/tx01v2/blob/main/terraform/modules/eks/nodes.tf), [AKS](https://github.com/maringelix/tx02v2/blob/main/terraform/modules/aks/main.tf), [GKE](https://github.com/maringelix/tx03v2/blob/main/terraform/modules/gke/main.tf). | R10.1: escala sob carga, controlador EKS, opções Spot por cloud e provas observáveis. |
| Três aplicações React + Node.js | Três implantações da **mesma** aplicação Express/React/PostgreSQL, para comparar as clouds; não são três produtos distintos. O deploy real segue sem execução. [AWS](https://github.com/maringelix/dx01v2/blob/main/README.md), [Azure](https://github.com/maringelix/dx02v2/blob/main/README.md), [GCP](https://github.com/maringelix/dx03v2/blob/main/README.md). | R7.2 e R11.1: releases e trilhas completas de cada par; status cloud separado. |
| IaC, redes, registries, identidade e GitHub Actions | VPC/VNet, subnets, ECR/ACR/Artifact Registry, RBAC, segredos e autenticação federada estão construídos; CI valida código, contratos e renders. Isso não comprova permissões e conectividade em contas reais. [Contrato AWS](https://github.com/maringelix/tx01v2/blob/main/docs/CONTRATO.md), [Azure](https://github.com/maringelix/tx02v2/blob/main/docs/CONTRATO.md), [GCP](https://github.com/maringelix/tx03v2/blob/main/docs/CONTRATO.md). | R8.1: fechar tutorial de fork/perfis, TLS/DNS/WAF e testes negativos de fronteiras/IAM; revisar contratos coordenadamente. |
| ALB/Gateway, WAF e SSL/TLS automático | Edge e políticas WAF existem. AWS aceita certificado ACM fornecido. Azure/GCP têm listener HTTP; HTTPS está explicitamente planejado. HTTPS com cert-manager/CA do lab é local. [Azure Gateway](https://github.com/maringelix/dx02v2/blob/main/deploy/k8s/components/azure/gateway.yaml), [GCP Gateway](https://github.com/maringelix/dx03v2/blob/main/deploy/k8s/components/gcp/gateway.yaml). | R8.1: DNS, emissão/renovação automática, redirect e smoke HTTPS nas três clouds, com caminhos offline verificáveis. |
| SonarQube, SAST e gates de qualidade/segurança | Há eslint/tsc, Vitest/coverage, gitleaks e Trivy de configuração/imagens. SonarQube e um gate dedicado de SAST não estão implementados. [Registro dos checks](https://github.com/maringelix/dx01v2/blob/main/scripts/harness.sh). | R7.1: SonarQube real, quality gate bloqueante, SAST, relatórios e caso negativo que prove o bloqueio. |
| CI/CD e zero downtime | CI testa o mesmo artefato entre build e kind. Deploy cloud reconstrói as imagens; não promove o digest já validado. Rollout local mantém disponibilidade, mas só troca tags do mesmo conteúdo. [CI](https://github.com/maringelix/dx01v2/blob/main/.github/workflows/ci.yml), [deploy](https://github.com/maringelix/dx01v2/blob/main/scripts/deploy-aws.sh), [limite da prova](https://github.com/maringelix/dx01v2/blob/main/docs/LAB_LOCAL.md). | R7.2: construir uma vez, promover por digest após gates, release com mudança real, migração compatível e rollback exercitado. |
| GitOps/Argo CD | Publicação de revisão, Synced/Healthy e self-heal existem, com provas locais. Os workflows DX usam GitOps e exigem plataforma cloud `full`. [Deploy local](https://github.com/maringelix/dx01v2/blob/main/scripts/deploy-local.sh), [runbook](https://github.com/maringelix/dx01v2/blob/main/docs/RUNBOOK.md). | R7.2/R8.1: ensinar release/rollback e corrigir o percurso `core`/`full` do fork. |
| Service mesh e traffic management avançado | Istio ambient/mTLS/policies existem localmente e no instalador EKS/AKS; GCP cloud omite Istio. Não há exercício completo de canário, timeout/retry e circuit breaking. [Charts GCP](https://github.com/maringelix/tx03v2/blob/main/platform/full/charts.txt). | R8.2: integrar apps/policies e tráfego avançado; implementar opção de mesh suportada no Autopilot, com limites e custos claros. |
| Prometheus, Grafana, Alertmanager, logs, OpenTelemetry e Cloud Monitoring | Stack local e charts cloud existem; API correlaciona traces/logs/exemplars e exporta para backends nativos. GKE configura logging. ServiceMonitor, regras e dashboard do app estão no componente local, sem integração equivalente completa nos overlays cloud. [App local](https://github.com/maringelix/dx01v2/blob/main/deploy/k8s/components/local-platform/monitoring.yaml), [componente cloud](https://github.com/maringelix/dx01v2/blob/main/deploy/k8s/components/aws/kustomization.yaml), [telemetria](https://github.com/maringelix/dx01v2/blob/main/api/src/telemetry.ts). | R8.3: integrar apps cloud, métricas/logs/traces, dashboards, alertas e Cloud Monitoring; persistência e retenção operacional opcionais. |
| Alertas Slack e monitoramento 24/7 | Receiver Slack opcional existe e o fluxo local usa um sink. Sem webhook não há entrega externa. Grafana/Tempo/Loki usam armazenamento efêmero e retenção curta. [Slack](https://github.com/maringelix/tx01v2/blob/main/platform/values/full/kube-prometheus-stack-slack.yaml), [Grafana](https://github.com/maringelix/tx01v2/blob/main/platform/local/values/kube-prometheus-stack.yaml), [Tempo](https://github.com/maringelix/tx01v2/blob/main/platform/local/values/tempo.yaml), [Loki](https://github.com/maringelix/tx01v2/blob/main/platform/local/values/loki.yaml). | R8.3: persistência, recuperação e teste de notificação. Entrega real ao Slack exige webhook do operador; 24/7 não é evidência de um lab efêmero. |
| OPA Gatekeeper e Trivy runtime | Admissão e relatórios locais são exercitados; constraints cloud existem. Trivy Operator cloud não recebe as credenciais necessárias aos registries privados. [Políticas](https://github.com/maringelix/tx01v2/blob/main/platform/full/policies/constraints/allowed-repos.yaml), [limite Trivy](https://github.com/maringelix/tx01v2/blob/main/platform/values/full/trivy-operator.yaml). | R8.4: credenciais mínimas, relatórios privados, provas de bloqueio e observação runtime. |
| PostgreSQL HA/Multi-AZ e backups automatizados | RDS permite Multi-AZ, mas default é `false` e retenção de um dia. Azure não configura HA nem backup georredundante. Cloud SQL é ZONAL, sem PITR, retém um backup e o remove com a instância. [RDS](https://github.com/maringelix/tx01v2/blob/main/terraform/envs/lab/variables.tf), [Azure](https://github.com/maringelix/tx02v2/blob/main/terraform/modules/postgres/main.tf), [Cloud SQL](https://github.com/maringelix/tx03v2/blob/main/terraform/modules/cloudsql/main.tf). | R9.1: perfil HA explícito, retenção/PITR, proteção dos dados e exercícios de restauração. Default barato continua identificado como tal. |
| Backup/restore Kubernetes e banco | Velero prova restauração de um ConfigMap com `snapshotVolumes: false`. DX prova pg_dump/restore do banco local. Nenhuma dessas provas equivale a recuperação conjunta de dados/PVs ou DR entre regiões. [Velero](https://github.com/maringelix/tx01v2/blob/main/platform/local/check.sh), [banco local](https://github.com/maringelix/dx01v2/blob/main/scripts/e2e-platform.sh). | R9.1/R9.2: backup agendado, dados/PVs quando usados, restore isolado e recuperação integrada. |
| Disaster Recovery multi-region | Não implementado; o escopo reduzido o havia retirado. | R9.2: região B simulada localmente, IaC cloud de DR, failover/failback e medição de RTO/RPO com dados reais do exercício. |
| Chaos Engineering | Local tem hipóteses para pod-kill, latência e stress; app mede disponibilidade e spans. GCP cloud limita Chaos Mesh a pod-kill. [Provas locais](https://github.com/maringelix/tx01v2/blob/main/platform/local/check.sh), [GCP](https://github.com/maringelix/tx03v2/blob/main/platform/values/full/chaos-mesh.yaml). | R8.4/R9.2/R10.1: exercícios portáveis, falha de nó/região simulada, rollback e recuperação; alternativa suportada em Autopilot. |
| FinOps e otimização avançada | Budgets, custos documentados e Spot EKS existem. Faltam showback/OpenCost, VPA, carga/HPA medida e opções Spot coordenadas em AKS/GKE. [Custos AWS](https://github.com/maringelix/tx01v2/blob/main/docs/CUSTOS.md), [Azure](https://github.com/maringelix/tx02v2/blob/main/docs/CUSTOS.md), [GCP](https://github.com/maringelix/tx03v2/blob/main/docs/CUSTOS.md). | R10.1/R10.2: métricas de capacidade/custo, VPA em recomendação, budgets/limites e comparação antes/depois. |

## Dois caminhos de fork precisam ficar consistentes

O [FORK AWS](https://github.com/maringelix/tx01v2/blob/main/FORK.md) ainda descreve um workflow DX
de push para `core`, mas o [workflow DX](https://github.com/maringelix/dx01v2/blob/main/.github/workflows/deploy-aws.yml)
fixa `DEPLOY_MODE: gitops`. Os runbooks DX de
[AWS](https://github.com/maringelix/dx01v2/blob/main/docs/RUNBOOK.md),
[Azure](https://github.com/maringelix/dx02v2/blob/main/docs/RUNBOOK.md) e
[GCP](https://github.com/maringelix/dx03v2/blob/main/docs/RUNBOOK.md) exigem `full` para GitOps,
enquanto a plataforma cloud oferece `core` como default.

R8.1 deve ensinar e verificar ambos os percursos: `core` com o script de push documentado, ou
`full` com Argo CD e o workflow GitOps. Cada fork configura suas próprias identidades, variáveis,
environments, domínios e integrações. Nenhuma configuração externa é presumida como copiada.

## SonarQube gratuito: aceite sem prometer recurso comercial

R7.1 deve oferecer SonarQube Community Build local e análise de `main` no CI, com quality gate
bloqueando a promoção. A documentação oficial limita Community Build à análise da branch principal;
não prometer análise nativa multibranch/decoração de PR. A falha do gate deve falhar o workflow por
Quality Gate Check Action ou `sonar.qualitygate.wait=true`.
[Integração oficial GitHub Actions](https://docs.sonarsource.com/sonarqube-community-build/devops-platform-integration/github-integration/adding-analysis-to-github-actions-workflow).

O gate de SAST de PR precisa de um caminho gratuito e reproduzível, sem depender de secrets do
repositório de origem. SonarQube Cloud pode ser uma extensão configurada pelo dono do fork: o plano
Free limita PRs ao destino `main`; a oferta OSS tem condições próprias.
[Planos oficiais](https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-subscription/subscription-plans).
Documentar as licenças dos componentes fixados: o
[core](https://github.com/SonarSource/sonarqube/blob/master/README.md) e o
[analyzer JavaScript](https://raw.githubusercontent.com/SonarSource/SonarJS/master/LICENSE.txt) têm
licenças diferentes. Análise de qualidade não substitui os demais scanners e as provas negativas.

## GKE Autopilot permanece contemplado

R8.2 deve entregar um caminho suportado no Autopilot, com configuração/IaC, políticas, tráfego e
exercícios correspondentes. A documentação do Google exige **managed Cloud Service Mesh** para
Autopilot em vez de control plane in-cluster. A ausência atual de ambient não fecha o item de mesh;
é uma limitação a resolver. [Plataformas suportadas](https://docs.cloud.google.com/service-mesh/docs/supported-platforms).

## Plano de construção: 22 PRs

| Rodada | IDs e resultado | PRs planejados |
|---|---|---:|
| R7 — DevSecOps e release | R7.1 gates/Sonar/SAST; R7.2 mesmo digest, release, migração e rollback | 3 DX |
| R8 — Plataforma cloud integrada | R8.1 edge/fork; R8.2 mesh; R8.3 observabilidade; R8.4 runtime/chaos | 3 TX + 3 DX |
| R9 — Dados e recuperação | R9.1 HA/backup/PITR; R9.2 DR multi-region | 3 TX + 3 DX |
| R10 — Capacidade e FinOps | R10.1 escala/carga/Spot; R10.2 custos/OpenCost/VPA | 3 TX + 3 DX |
| R11 — Aceite e ensino | R11.1 currículo, evidências, limites e percurso completo por cloud | 1 hub |
| **Total** | Um PR por repositório em cada rodada; docs e aulas acompanham a implementação | **22** |

É uma previsão por entregas coesas, sujeita a incompatibilidades reais; não há PR separado por
ferramenta. A revisão documental atual não conta como implementação dessas capacidades.
Os três DX mantêm paridade da aplicação; TX e DX coordenam e versionam contratos.

## Definição verificável de pronto

- Cada tecnologia tem configuração executável, aula, pré-requisitos, exercício, resultado esperado,
  falha intencional, recuperação, custo e teardown; a matriz liga o requisito ao check e ao PR.
- CI bloqueia regressões e demonstra que gates vermelhos impedem promoção; a entrega usa o digest
  aprovado e mede disponibilidade durante uma alteração real e seu rollback.
- Backup/DR restaura dados verificáveis; RPO usa transações/timestamps e RTO inclui falha, recuperação
  e estabilização. Failback e reconciliação fazem parte do exercício.
- Docker simula regiões independentes para ensinar o procedimento; não comprova isolamento
  geográfico, SLA, failover gerenciado ou RTO/RPO de produção.
- FinOps distingue estimativa/simulação de fatura medida. Custos incluem HA, segunda região,
  replicação/egress, retenção, observabilidade, DNS/LB/WAF/NAT/IP. Budget é alerta, não limite rígido.
- O perfil barato é o ponto de entrada; `full` e HA/DR têm custos explícitos. A DEC-12 mantém
  `small` em 7 GB; perfis novos precisam publicar seu próprio orçamento de memória e tempo.
- Construção pode ser concluída com Docker, renders, testes mockados e GitHub Actions. Homologação
  real exige rodada separada por cloud, conta/orçamento e autorização; mantém status próprio.
- PR mergeado não basta para afirmar “produção”, “24/7”, “custo otimizado” ou “todo o escopo pronto”.
  A DEC-13 só se encerra com os aceites R7–R11 e a matriz final completa.
