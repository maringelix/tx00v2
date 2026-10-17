# Matriz de aceite da construção do lab

Escopo construído: DEC-13, R7–R11, 22 PRs (21 de implementação e este fechamento do hub). O [currículo](CURRICULO.md) contém
pré-requisitos, objetivo, comandos, falha, aceite, diagnóstico, recuperação, custo e
limpeza de cada aula. O [roadmap](../ROADMAP.md) registra os PRs de cada entrega.

Construção e execução são estados separados. A v2 contém código de infraestrutura
e aplicação para as três clouds; os testes executáveis usam mocks, Docker e kind
no Actions. Nada da v2 foi homologado em conta cloud real.

## Requisito × implementação × prova × limite

| Requisito | AWS | Azure | Google Cloud | Prova de construção/CI e limite | Rodadas/PRs |
|---|---|---|---|---|---|
| Três Kubernetes | EKS | AKS | GKE Autopilot | IaC e providers mockados; kind real no CI. Control planes gerenciados ainda sem execução | R8/R10 |
| Aplicação full stack | dx01v2 | dx02v2 | dx03v2 | Mesmo React/Express/Node/PostgreSQL, intencionalmente; testes unitários/integração, imagem, smoke e e2e | R7/R8 |
| Terraform e redes | VPC, subnets públicas/privadas, NAT | VNet, subnets e CNI Overlay/Cilium | VPC, private nodes, PSC/Cloud SQL | Validações recusam entradas abertas/sobrepostas; não demonstram roteamento da conta real | R8/R9 |
| Estado e IaC | S3/KMS/versionamento | Blob/locks/versionamento | GCS/versionamento | Estado separado, recuperação opt-in, proteção/retidos; não há failover automático do backend | R9 |
| Identidade e least privilege | OIDC + EKS Pod Identity | OIDC + Entra Workload ID | WIF + KSA principals | Trusts, escopos, condicionais, boundary/ABAC e contratos em testes; sem chaves estáticas | R8/R9 |
| Registry | ECR | ACR | Artifact Registry | Artefato por digest e contrato; nenhuma credencial de registry gravada no app | R7/R9 |
| CI/CD e segurança | GitHub Actions | GitHub Actions | GitHub Actions | Harness obrigatório, cobertura, CodeQL, Trivy, gitleaks, SonarQube e ZAP reais/fixtures negativas | R7 |
| SonarQube/SAST | Community Build e quality gate | Mesmo fluxo | Mesmo fluxo | Análise isolada e resultado do gate; não depende de edição comercial multibranch | R7 |
| Cadeia de artefatos | SBOM, proveniência, assinatura keyless | Mesmo fluxo | Mesmo fluxo | SHA/checksum/identidade/emissor aprovados; promoção sem rebuild e recusa de artefato trocado | R7/R8 |
| GitOps e deploy | Argo CD | Argo CD | Argo CD | Rollout com revisões diferentes, tráfego contínuo, falha de readiness e rollback; sem promessa de zero erro para qualquer mudança futura | R7/R8 |
| Load balancing e DNS | ALB/Route53 | AGC/Azure DNS | Gateway/Cloud DNS | Contratos/manifests/IAM, HTTPS no Gateway local e smoke regional forçando destino antes do DNS | R8/R9 |
| TLS automático | ACM | cert-manager/ACME | Certificate Manager | CA/SNI/redirect locais; emissão/renovação em domínio público ainda sem prova cloud | R8/R9 |
| WAF | AWS WAF | WAF do AGC | Cloud Armor | Regras e associação em IaC/contrato; o motor de cada WAF precisa de homologação própria | R8 |
| Mesh e tráfego | Istio ambient | Istio ambient | Cloud Service Mesh gerenciado/sidecar | Kind prova mTLS, identidade, canary, retry/outlier e isolamento. Autopilot não recebe o daemon ambient privilegiado | R8 |
| Métricas/alertas | Prometheus/Grafana/Alertmanager + integrações AWS | Stack + Application Insights | Stack + Cloud Trace/Cloud Monitoring | Targets, regras/SLO, receiver HTTP sintético e Slack em emulador; exportação gerenciada é validada como configuração | R8 |
| OpenTelemetry/logs | Collector/X-Ray + Loki/Tempo | Collector/App Insights + Loki/Tempo | Collector/Cloud Trace + Loki/Tempo | Trace edge→API→SQL, logs e exemplars correlacionados; retenção/PVC em código, sem alegar monitoramento operado 24/7 | R8 |
| Policies de runtime | Gatekeeper/OPA, Kyverno, PSA, NetworkPolicy | Mesmo conjunto | Conjunto compatível com Autopilot | Pod/identidade/artefato indevido negado; scanner produz relatórios. Não se remove um gate para concluir | R8 |
| PostgreSQL HA | RDS multi-AZ opt-in | Flexible Server ZoneRedundant opt-in | Cloud SQL regional opt-in | Perfis baratos/HA/DR e parâmetros testados; failover gerenciado não é inferido do kind | R9 |
| Backup/PITR | RDS + backup físico local | Backup PostgreSQL + físico local | Cloud SQL + físico local | Basebackup/WAL/restore point, corrupção recusada, dados corretos e reconnect; native PITR cloud precisa de rodada própria | R9 |
| Backup de volumes | Velero FSB/Kopia/S3 | Velero FSB/Kopia/Blob | Velero CSI/Persistent Disk/GCS | PVC com bytes originais apagados, nova claim e checksum restaurado. CSI PD cloud e Blob/S3 nativos ainda sem execução | R9 |
| DR multi-region | Runtime/rede/DB/ECR/segredos/backup secundários | Runtime/rede/DB/ACR/cofre/config secundários | Runtime/rede/DB/registry/segredos/config secundários | IaC das regiões + A/B Docker independente, fencing, perda total, RPO/RTO e failback com dados; sem promoção automática | R9 |
| Chaos Engineering | Pod/network/CPU/memory | Pod/network/CPU/memory | PodChaos sem daemon privilegiado; falhas HTTP/latência pela malha | Chaos completo no kind com hipótese/SLO/recuperação; a superfície Autopilot é explicitamente menor | R8/R10 |
| Autoscaling de nós | Cluster Autoscaler real e tags ASG | Autoscaler gerenciado habilitado | Capacidade Autopilot por requests | IaC/IAM e minor compatível; aumento/redução de nós gerenciados ainda sem prova cloud | R10 |
| Spot e fallback | Pool Spot tainted opcional + baseline on-demand | Pool user Spot tainted + system regular | Job Spot finito + alternativa on-demand | Kind prova interrupção/drain/PDB/rescheduling; disponibilidade e desconto Spot não são garantidos | R10 |
| HPA e carga | Mesmo cenário do app | Mesmo cenário | Mesmo cenário | HPA up/down, SLO no Gateway, quota recusando excesso e saturação/recuperação do pool PostgreSQL | R10 |
| FinOps | OpenCost com preços AWS revisados | Preços Azure revisados | Preços GCP revisados | Alocação medida, owner/ambiente, idle/shared e externos; fixtures determinísticas não são cotações | R10 |
| Rightsizing | VPA Off | VPA Off | VPA gerenciado Off | Recomendação sem mutação, comparação de requests/replicas e SLO antes/depois; redução de request não implica economia de fatura | R10 |
| Budget/expiração/limpeza | Mesmo gate e inventário do TX | Mesmo gate e inventário do TX | Mesmo gate e inventário do TX | Plano privado, preços completos, limite estimado, prazo <=24 h, carga com deadline, teardown/leftovers. Budget não limita cobrança e cloud destroy continua manual | R10 |
| Fork e paridade | Contrato v7 | Contrato v5 | Contrato v5 | CI em runners limpos sem secrets cloud; family verifica contratos, pins, versões, digests e app. Uma segunda conta GitHub real não foi usada | R7/R8/R9/R10/R11 |

## Fontes executáveis

| Camada | AWS | Azure | GCP |
|---|---|---|---|
| Infraestrutura e perfis | [tx01v2](https://github.com/maringelix/tx01v2/tree/main/terraform) | [tx02v2](https://github.com/maringelix/tx02v2/tree/main/terraform) | [tx03v2](https://github.com/maringelix/tx03v2/tree/main/terraform) |
| Plataforma cloud/local | [platform](https://github.com/maringelix/tx01v2/tree/main/platform) | [platform](https://github.com/maringelix/tx02v2/tree/main/platform) | [platform](https://github.com/maringelix/tx03v2/tree/main/platform) |
| App, overlays e probes | [dx01v2](https://github.com/maringelix/dx01v2) | [dx02v2](https://github.com/maringelix/dx02v2) | [dx03v2](https://github.com/maringelix/dx03v2) |
| Continuidade | [runbook TX](https://github.com/maringelix/tx01v2/blob/main/docs/CONTINUIDADE.md) | [runbook TX](https://github.com/maringelix/tx02v2/blob/main/docs/CONTINUIDADE.md) | [runbook TX](https://github.com/maringelix/tx03v2/blob/main/docs/CONTINUIDADE.md) |
| Capacidade/FinOps | [runbook TX](https://github.com/maringelix/tx01v2/blob/main/docs/FINOPS.md) | [runbook TX](https://github.com/maringelix/tx02v2/blob/main/docs/FINOPS.md) | [runbook TX](https://github.com/maringelix/tx03v2/blob/main/docs/FINOPS.md) |

Os links de PR no roadmap são conferidos contra commits mesclados na main.
Os links de CI dos PRs apontam para revisões específicas: verificado no CI descreve
o que aquele teste executou, não uma homologação implícita em três clouds.

## PRs de construção por rodada

A última coluna da matriz remete às evidências abaixo. O registro legível por máquina
está em [ENTREGAS.json](ENTREGAS.json); R11 corresponde ao fechamento deste hub.

| Rodada | AWS | Azure | Google Cloud |
|---|---|---|---|
| R7 | [dx01v2#17](https://github.com/maringelix/dx01v2/pull/17) | [dx02v2#12](https://github.com/maringelix/dx02v2/pull/12) | [dx03v2#14](https://github.com/maringelix/dx03v2/pull/14) |
| R8 | [tx01v2#16](https://github.com/maringelix/tx01v2/pull/16), [dx01v2#18](https://github.com/maringelix/dx01v2/pull/18) | [tx02v2#14](https://github.com/maringelix/tx02v2/pull/14), [dx02v2#13](https://github.com/maringelix/dx02v2/pull/13) | [tx03v2#15](https://github.com/maringelix/tx03v2/pull/15), [dx03v2#15](https://github.com/maringelix/dx03v2/pull/15) |
| R9 | [tx01v2#17](https://github.com/maringelix/tx01v2/pull/17), [dx01v2#19](https://github.com/maringelix/dx01v2/pull/19) | [tx02v2#17](https://github.com/maringelix/tx02v2/pull/17), [dx02v2#14](https://github.com/maringelix/dx02v2/pull/14) | [tx03v2#16](https://github.com/maringelix/tx03v2/pull/16), [dx03v2#16](https://github.com/maringelix/dx03v2/pull/16) |
| R10 | [tx01v2#18](https://github.com/maringelix/tx01v2/pull/18), [dx01v2#20](https://github.com/maringelix/dx01v2/pull/20) | [tx02v2#18](https://github.com/maringelix/tx02v2/pull/18), [dx02v2#15](https://github.com/maringelix/dx02v2/pull/15) | [tx03v2#17](https://github.com/maringelix/tx03v2/pull/17), [dx03v2#17](https://github.com/maringelix/dx03v2/pull/17) |
| R11 | Este fechamento do tx00v2: currículo, matriz e checks da família | Mesmo hub | Mesmo hub |

## Homologação cloud

Checklist de execução futura, pelo dono do fork:

1. Escolher uma cloud por vez, conta/projeto dedicado e janela; conferir limites de
   créditos/serviços/região na própria conta. Não assumir que o conjunto full/HA/DR cabe no free tier.
2. Fork/configuração própria, rulesets, environment lab protegido e identidades OIDC.
   Habilitar Actions, alinhar TX0NV2_REPO e pin; CI completo primeiro.
3. Revisar preços regionais atuais, SKU máximo e DR; preencher budget/duração/expiração,
   domínio/DNS e webhook próprios. Preservar chaves de repositório de backup quando exigidas.
4. Bootstrap, plano revisado, apply, plataforma e promoção pelo workflow existente;
   nenhuma execução fora dos escopos e nomes do lab.
5. Registrar controles gerenciados: TLS público, WAF, federação, traces/monitoring/Slack,
   retenção, scaling de nós, Spot/fallback e custo real.
6. Ensaiar backup/PITR em destino isolado e DR com fencing; verificar marcadores,
   versão/certificado/destino antes de cutover, medir RPO/RTO e ensaiar failback.
7. Destruir ao encerrar a janela, conferir ambas as regiões e inventário de sobras.
   Recursos retidos, versões, snapshots e chaves têm custo/decisão separados.
8. Publicar cloud_run_report com resultados e falhas, sem segredos/identificadores.
   Corrigir problemas encontrados em novos PRs; não mudar retroativamente a evidência local.

## Sustentação

O fechamento da construção não termina manutenção: acompanhar CVEs, pins,
depreciações de Kubernetes/providers/charts, data das tarifas, quotas, certificados,
backup age/replica lag e retenção. Seguir docs/SUSTENTACAO.md de cada repositório
e o CI semanal do hub. Domínio, operação contínua e contas são do dono de cada fork.
