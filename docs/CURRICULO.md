# Currículo do lab completo

O mesmo app React + Node.js + PostgreSQL é entregue por três pares independentes:
[AWS](https://github.com/maringelix/tx01v2),
[Azure](https://github.com/maringelix/tx02v2) e
[Google Cloud](https://github.com/maringelix/tx03v2).
Use o [aceite](ACEITE_FINAL.md) para distinguir construção, prova no CI e homologação cloud.

## Preparação e trilhas

Pré-requisitos: Git, Bash >=4.4, Linux/WSL2 ou devcontainer; Docker e Node 24 nos
apps. make tools instala ferramentas fixadas por versão e checksum. Não é preciso
conta cloud para aprender a aplicação e a plataforma local.

| Trilha | Ordem | Ambiente e custo |
|---|---|---|
| Fundamentos | A01–A06 | Checks leves e CI público; sem conta cloud |
| Plataforma e operação | A07–A14 | kind full: 8 GiB; small: 7 GiB; pesado no Actions |
| Capacidade e custo | A15–A16 | kind HA com três nós: recomenda 12 GiB; não combine com small |
| Homologação futura | A17 | Conta/projeto dedicado, domínio e orçamento do dono do fork |

Faça uma aula por vez. Registre revisão Git, comando, resultado, falha observada,
recuperação e limpeza. Em falha de gate, corrija a causa; não transforme indisponibilidade
ou ausência de ferramenta em aprovação. Os jobs conservam seus limites de tempo.

### A01 — Fork, contratos e isolamento

- Pré-requisito: conta GitHub e [FORK.md](../FORK.md).
- Arquitetura/objetivo: um TX publica contrato versionado e um DX consome suas
  identidades/endereços; o DX fixa a revisão do TX usada no kind.
- Executar: make static nos dois repos; make family no hub após configurar o owner.
- Falha: use um parâmetro fora do formato ou uma revisão que não existe no fork.
- Sucesso: contrato recusa o valor; uma configuração limpa passa sem credenciais
  do mantenedor. Diagnóstico: contract-app, family-contract e family-ref.
- Recuperar: alinhar os dois contratos e o pin, sem copiar conta/secret do upstream.
- Custo/limpeza: checks leves; apagar somente scratch de execução, preservar o fork.

### A02 — Terraform, rede e estado

- Pré-requisito: A01; docs/ARQUITETURA.md e docs/RUNBOOK.md do TX escolhido.
- Arquitetura/objetivo: módulos, providers, estado remoto versionado, redes/subnets
  privadas, DNS, roteamento/NAT e banco privado; entender plano, drift e dependências.
- Executar: make static e make test no TX (providers mockados, nenhuma conta necessária).
- Falha: CIDR sobreposto/público, banco aberto, retenção inválida ou state recovery
  configurado para a região primária. Sucesso: testes negativos recusam o plano.
- Diagnóstico/recuperação: validações, provider schema, IAM e plano; corrigir entradas,
  manter locks/versões e nunca editar uma migração aplicada nem destruir state por tentativa.
- Custo/limpeza: rede/estado/NAT cobrados somente numa rodada cloud; seguir destroy e
  inventário do TX. Bucket/chave retidos exigem decisão explícita do operador.

### A03 — EKS, AKS e GKE Autopilot

- Pré-requisito: A02 e fundamentos de pods, Service, Deployment e probes.
- Arquitetura: EKS com Pod Identity e Cluster Autoscaler; AKS com Workload Identity
  e autoscaler gerenciado; GKE Autopilot com Workload Identity Federation e capacidade gerenciada.
- Executar: make e2e no TX em Actions; inspecionar o contrato local lab-system/lab-contract.
- Falha: pod sem readiness/resources ou em nó indisponível. Sucesso: estado/eventos
  explicam Pending/NotReady e a sonda comprova retomada, sem tratar kind como EKS/AKS/GKE.
- Diagnóstico/recuperação: events, rollout, scheduler, requests e identidade do controller.
- Custo/limpeza: kind consome o runner; serviços gerenciados só após A17. Sempre local-down
  pelo mesmo estado que criou o cluster e leftovers-local depois.

### A04 — Aplicação full stack e PostgreSQL

- Pré-requisito: A01/A03; docs/API.md e docs/MIGRATIONS.md do DX.
- Arquitetura: React servido por nginx, Express/TypeScript, pool PostgreSQL e migrations.
- Executar: make test e make e2e no DX; testes de integração usam PostgreSQL descartável.
- Falha: entrada inválida, token ausente, banco indisponível ou migração incompatível.
- Sucesso: validação/HTTP corretos, cobertura obrigatória, banco não exposto e reconnect.
- Diagnóstico/recuperação: logs estruturados sem tokens, métricas de pool, readiness e checksum
  de migration; preparar expand/contract e restauração antes de alterações destrutivas.
- Custo/limpeza: Compose/kind descartável; nunca apontar testes que apagam tabelas para um banco real.

### A05 — DevSecOps e quality gates

- Pré-requisito: A04; docs/SEGURANCA_CI.md.
- Arquitetura: CI com SonarQube Community Build/quality gate real, CodeQL/SAST,
  Trivy, gitleaks, cobertura e OWASP ZAP; promoção depende dos resultados.
- Executar: jobs static/test/images; make dast para o cenário ZAP isolado no Actions.
- Falha: fixtures de código sem cobertura, alerta SAST, segredo fictício ou DAST reprovado.
- Sucesso: o gate negativo bloqueia a entrega, e a versão corrigida passa. Sonar Community
  analisa a revisão isolada sem exigir um serviço comercial de multibranch.
- Diagnóstico/recuperação: relatórios do scanner e gate; corrigir código/entrada ou exceção
  justificada com prazo. Sem bypass ou redução de cobertura.
- Custo/limpeza: containers Sonar/PostgreSQL/ZAP são transitórios no CI; stop/teardown mesmo em falha.

### A06 — Imagens, SBOM e cadeia de entrega

- Pré-requisito: A05; docs/SEGURANCA_CI.md e docs/RUNBOOK.md.
- Arquitetura: imagem por digest, SBOM, proveniência e assinatura keyless; ECR, ACR
  ou Artifact Registry recebem o artefato aprovado sem recompilar durante deploy.
- Executar: job images, workflow publish-images e verificação do release bundle descritos no DX.
- Falha: SHA diferente, checksum trocado, assinatura ausente ou identidade/emissor inesperados.
- Sucesso: publicação/promoção recusa o artefato; somente a revisão com os gates verdes avança.
- Diagnóstico/recuperação: metadados do run, atestações e identidade OIDC; republicar pelo fluxo aprovado.
- Custo/limpeza: retenção/registry do fork; sem chaves estáticas cloud e sem publicar bundles privados.

### A07 — GitOps, deploy declarativo e rollback

- Pré-requisito: A06; plataforma full do TX.
- Arquitetura: Argo CD, repo GitOps, sync/self-heal, readiness, PDB e RollingUpdate.
- Executar: make e2e-platform no DX; há versões com conteúdo diferente e rollback induzido.
- Falha: imagem que nunca fica pronta ou revisão/migration reprovada. Sucesso: teste
  verifica tráfego durante rollout e volta ao conteúdo anterior após a falha.
- Diagnóstico/recuperação: Application, eventos e revision/image IDs; reverter para artefato conhecido.
  Rollback do app e recuperação de dados são operações diferentes.
- Custo/limpeza: perfil full; parar reconciliador antes de retirar Gateway/Ingress para não recriar LB.

### A08 — Entrada, DNS, TLS e WAF

- Pré-requisito: A03/A07; docs/CONTRATO.md e docs/RUNBOOK.md de cada par.
- Arquitetura: AWS ALB/ACM/Route53/WAF; Azure AGC/cert-manager/ACME/DNS/WAF;
  GCP Gateway/Certificate Manager/Cloud DNS/Cloud Armor.
- Executar: render/validação dos overlays cloud e HTTPS local pelo Gateway.
- Falha: certificado não confiável, rota/identidade indevida ou certificado regional errado.
- Sucesso: CA/SNI/redirect/revisão corretos; manifests/IaC verificam escopo das regras de WAF.
  O motor WAF e a emissão pública gerenciada exigem prova cloud, não são demonstrados pelo kind.
- Diagnóstico/recuperação: Certificate/Gateway/Ingress/HTTPRoute, DNS e políticas;
  recuperar o TLS antes de smoke pré-DNS em DR, conforme o runbook do par.
- Custo/limpeza: domínio/LB/WAF cobrados em cloud; remover controladores/recursos externos antes da rede.

### A09 — Service mesh e tráfego avançado

- Pré-requisito: A07; Istio, mTLS, Gateway API e identidade de workload.
- Arquitetura: ambient no kind/EKS/AKS; perfil GCP usa o caminho suportado de mesh gerenciada/sidecar.
- Executar: sondas mesh avançadas do e2e-platform: canary, retry e isolamento/outlier.
- Falha: intruso, backend com erro e canary defeituoso. Sucesso: política nega o intruso,
  percentuais/retries são observados e o backend saudável continua atendendo.
- Diagnóstico/recuperação: waypoint/sidecar, rotas, identidades e traces; reverter política/revisão.
- Custo/limpeza: requests do mesh no orçamento full; remover waypoint/rotas no teardown do par.

### A10 — Métricas, logs, traces e Slack

- Pré-requisito: A07/A09; Prometheus/Grafana/Alertmanager, Loki/Alloy, Tempo e OpenTelemetry.
- Arquitetura: correlação HTTP → API → PostgreSQL com trace/log/exemplar; alertas Slack
  via webhook configurável. Exportadores cloud usam X-Ray, Application Insights e Cloud Trace.
- Executar: sondas de observabilidade/tracing/alertas do TX e DX no Actions.
- Falha: alerta deliberado, dependência lenta ou target indisponível. Sucesso: métrica,
  log/trace correlacionado e payload do receptor Slack observáveis no emulador local.
- Diagnóstico/recuperação: targets, regras, pipeline/identidade e retenção; retirar o alerta
  e verificar recuperação. Não confundir um teste de entrega com operação 24/7.
- Custo/limpeza: retenção/PVC e ingestão cloud são orçados; excluir discos ou registrar retenção.

### A11 — Policies e segurança de runtime

- Pré-requisito: A05/A07; docs/GUARDRAILS.md e SEGURANCA_CI.md.
- Arquitetura: PSA restricted, Gatekeeper/OPA, NetworkPolicy, Kyverno e Trivy Operator;
  IAM/RBAC por workload, banco privado e secrets federados.
- Executar: testes gator/contract e sondas de admissão/scan do full.
- Falha: imagem não aprovada, pod sem probes/resources/labels, identidade intrusa ou regra de rede indevida.
- Sucesso: admissão/fluxo negado pelo motivo esperado; pod válido e relatório do scanner passam.
- Diagnóstico/recuperação: constraints, eventos, políticas e identidades; corrigir manifesto,
  sem liberar tudo nem desligar o webhook para continuar.
- Custo/limpeza: controladores full; não remover policies isoladamente para esconder um erro.

### A12 — HA, backup físico e PITR

- Pré-requisito: A04/A10; docs/CONTINUIDADE.md do TX/DX.
- Arquitetura: RDS multi-AZ, PostgreSQL Flexible Server HA e Cloud SQL regional como
  perfis opt-in; backups, retenção/PITR e proteção de deleção configuráveis.
- Executar: make e2e no TX e make continuity no DX, no CI.
- Falha: backup corrompido, gravação posterior ao ponto de recuperação e perda do banco.
- Sucesso: pg_verifybackup recusa corrupção; basebackup+WAL restaura o ponto escolhido,
  preserva a gravação válida e exclui a posterior; API reconecta.
- Diagnóstico/recuperação: catálogo/idade de backup, WAL/restore point e logs sem segredos.
- Custo/limpeza: HA/retidos/replicação adicionam cobrança; defaults e teardown estão no TX.

### A13 — Velero e DR entre regiões

- Pré-requisito: A12; fencing, RPO/RTO, chaves e backups independentes.
- Arquitetura: runtime/rede/banco/registry/secrets/config/estado na segunda região;
  destino de backup de recuperação com leitura limitada e chave escrow quando necessária.
- Executar: sonda Velero de bytes/PVC no TX; exercício A/B no DX.
- Falha: apagar bytes/PVC originais; perder o primário A; tentar promover com A vivo.
- Sucesso: nova claim recupera checksum; promoção sem fencing é recusada; B preserva
  dados restauráveis, grava, e failback para A novo conserva a gravação de B com RPO/RTO medidos.
- Diagnóstico/recuperação: réplicas/lag, Backup/Restore/PVB/PVR, revisão regional e
  smoke TLS pré-DNS; usar procedimentos específicos de cada provedor.
- Custo/limpeza: DR é opt-in, não replica automaticamente uma decisão de promoção.
  Inventariar ambas as regiões, discos, versões, registries, chaves e state retido.

### A14 — Chaos Engineering

- Pré-requisito: A10–A13; hipótese, SLO e janela limitada.
- Arquitetura: Chaos Mesh com escopo de namespace/labels e observação por métricas/traces.
- Executar: sondas pod-kill, latência de rede e stress de CPU/memória.
- Falha: retirar réplica ou atrasar PostgreSQL. Sucesso: hipótese medida, número de
  requisições/latência/restarts observado e recuperação após remover o experimento.
- Diagnóstico/recuperação: status AllInjected, eventos, traces e readiness; abortar no deadline.
- Custo/limpeza: somente objetos do experimento; agente privilegiado fica no namespace próprio.

### A15 — Autoscaling, Spot e gargalos

- Pré-requisito: A14 e [FINOPS do TX](https://github.com/maringelix/tx01v2/blob/main/docs/FINOPS.md).
- Arquitetura: HPA escala pods; CA/AKS/Autopilot governam capacidade; Spot é descartável,
  com mínimo crítico on-demand e fallback explícito na aula cloud.
- Executar: LOCAL_TOPOLOGY=ha LOCAL_FINOPS=1 make e2e (TX) e make e2e-platform (DX).
- Falha: carga/CPU, drenagem de worker, quota excedida e pool PostgreSQL saturado.
- Sucesso: HPA up/down real, PDB recusa último pod, rescheduling/SLO passam; saturação
  produz erro observável e recupera. O ensaio não comprova aumento de nós gerenciados.
- Diagnóstico/recuperação: requests/metrics-server, autoscaler, taints/afinidade/PDB,
  pool/locks; parar carga, descordonar nó e restaurar GitOps.
- Custo/limpeza: deadlines e máximos de pods/nós; kind HA no CI, Spot cloud só em A17.

### A16 — OpenCost, showback, VPA e estimativa

- Pré-requisito: A15; docs/FINOPS.md de ambos os repos.
- Arquitetura: OpenCost com preços regionais configurados, owner/ambiente, idle/shared,
  serviços externos; VPA Off recomenda sem competir com HPA por requests.
- Executar: sondas FinOps e relatório de capacity/rightsizing; no cloud plan, gate de custo.
- Falha: tarifa antiga/região errada/recurso sem preço/orçamento excedido/prazo vencido.
- Sucesso: cenário caro é negado; alocação real do namespace é positiva; candidato de
  requests mantém SLO e reporta réplicas/CPU agregados antes/depois.
- Diagnóstico/recuperação: targets, janela, fonte/moeda/data/unidades e serviços externos;
  atualizar tarifas ou reduzir escopo. Redução de request não equivale a economia faturada.
- Custo/limpeza: budget é alerta e gate é estimativa, sem teto financeiro; destruir ao
  expirar a rodada e registrar recursos retidos e custos remanescentes.

### A17 — Homologação real e operação do fork

- Pré-requisito: todas as aulas locais; [checklist de homologação](ACEITE_FINAL.md#homologação-cloud).
- Objetivo: comprovar diferenças gerenciadas que mocks/kind não demonstram.
- Executar: bootstrap/plan/apply/platform/deploy/smoke e recuperação conforme o RUNBOOK
  do par, com autorização, conta dedicada, limites de custo, domínio e janela próprios.
- Falha/sucesso: registrar emissão TLS pública, identidade, HA/PITR/DR nativo, escalabilidade,
  interrupção Spot e custos com evidência da conta; nenhum deles recebe aprovação por analogia.
- Diagnóstico/recuperação: cloud_run_report sem IDs/segredos, rollback e restauração ensaiados.
- Limpeza: destroy das duas regiões, inventário de sobras e retenções; a execução futura
  não é requisito para rodar nem para estudar a construção local.
