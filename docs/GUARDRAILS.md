# Guardrails da família v2

As regras que valem para os sete repositórios (os seis do lab e este hub) e onde cada uma é aplicada.
Cada repositório do lab tem o próprio `docs/GUARDRAILS.md`, com as regras da sua nuvem (IAM, rede,
contrato); quando uma regra daqui também está lá, o "Onde" aponta o check de cada lado.

Tipos: `bloqueante` (um check obrigatório falha), `alerta` (um check informativo falha: o `family`
deste hub) e `processo` (revisão e rotina, sem check automático).

## Regras

| ID | Regra | Por quê | Onde é aplicada | Tipo |
|---|---|---|---|---|
| SEC-01 | Nunca segredos nem identificadores reais (IDs de conta, assinatura, tenant e projeto, GUIDs, hostnames, IPs públicos, e-mails); só placeholders | repositórios públicos, que o time vai copiar | `gitleaks` e `policy-identifiers` em cada repositório e aqui | bloqueante |
| SEC-02 | A nuvem só por OIDC ou Workload Identity Federation, com `sub` exatos; nenhuma chave estática | uma chave vazada não expira sozinha | testes do bootstrap de cada tx; `policy-workflows` | bloqueante |
| SEC-03 | O `ci.yml` nunca pede `id-token: write`; OIDC só nos workflows de nuvem, com o environment `lab` | o CI de um PR não pode falar com a nuvem | `policy-workflows` dos sete | bloqueante |
| SEC-04 | O hub não tem credencial nem workflow de nuvem; o estágio `family` só lê repositórios públicos | o hub não aumenta a superfície de ataque | `policy-workflows` deste repositório | bloqueante |
| SUP-01 | Tudo fixado: ferramentas por versão + SHA256, actions por SHA de 40 caracteres + `# vX.Y.Z`, imagens por digest, charts por versão + SHA256, providers com lock files de quatro plataformas, npm exato com lockfile | build reprodutível e cadeia de suprimentos conferível | checks de cada repositório; `family-actions`, `family-digests`, `family-versions` aqui | bloqueante |
| SUP-02 | As versões compartilhadas são iguais na família: ferramentas dentro de cada papel (e entre os papéis, salvo exceção registrada), charts dos três tx, um digest por imagem, um pin por action | o mesmo lab nas três nuvens; uma diferença sem motivo é drift | `family-versions`, `family-digests`, `family-actions` | alerta |
| SUP-03 | Arquivos que precisam ser idênticos: `scripts/repo-guardrails.sh` nos seis; `LICENSE`, `CLAUDE.md` e `CODEOWNERS` nos sete; `.editorconfig`, `.gitattributes`, `.pre-commit-config.yaml` e o ruleset dentro de cada papel, mais `scripts/install-tools.sh` nos tx e `scripts/update-tool-checksums.sh` e `.nvmrc` nos dx; as migrações do app nos três dx | uma correção num repositório chega aos outros | `family-identical` | alerta |
| SUP-04 | Nada apodrece em silêncio: CI semanal, Dependabot mensal agrupado, calendário de fim de suporte, exceções de scanner com `statement` e `expired_at` de no máximo uns 7 meses | lab parado vira lab quebrado | `ci.yml` (schedule), `trivyignore-policy` de cada repositório, seção S do ROADMAP | bloqueante |
| CI-01 | O CI é o harness: os jobs só chamam `make <target>` | o que passa localmente passa no CI | revisão; `ci.yml` de cada repositório | processo |
| CI-02 | `HARNESS_STRICT=1` no CI: todo SKIP vira FAIL | nada é pulado em silêncio | `ci.yml` e `scripts/harness.sh` dos sete | bloqueante |
| CI-03 | Nunca enfraquecer um gate: nada de `continue-on-error`, `\|\| true` ou `\|\| echo` em check, `--no-verify`, check desligado, limite de cobertura baixado | um gate fraco dá falsa confiança | `policy-workflows` dos sete; revisão | bloqueante |
| CI-04 | Checks obrigatórios no ruleset: tx `static`, `test`, `e2e`; dx `static`, `test`, `images`, `e2e`, `e2e-platform`; hub `static` | o lab local é gate de merge, não disciplina | `.github/rulesets/main.json` + `scripts/repo-guardrails.sh` de cada repositório; `policy-workflows` aqui | bloqueante |
| CI-05 | Jobs com `runs-on: ubuntu-24.04`, `timeout-minutes`, `concurrency` e `permissions: contents: read` no topo; `persist-credentials: false` em todo checkout | runner previsível, sem job pendurado nem token sobrando | `policy-workflows` dos sete | bloqueante |
| MUD-01 | Uma rodada por vez: o item nasce no par de referência (tx01v2, dx01v2) e é portado na mesma rodada, um PR por repositório | os pares não se separam | revisão; ROADMAP seção 3 | processo |
| MUD-02 | O tx entra antes do dx; o PR do dx fixa o commit mesclado do tx em `deploy/local/tx0Nv2.ref`, e nenhum commit depois dele muda o lab local | o e2e-platform do dx testa a plataforma atual | `family-ref` | alerta |
| MUD-03 | Contrato versionado: mudança só com PRs coordenados nos dois lados e versão nova; o título do `docs/CONTRATO.md` é igual nos dois lados e a versão do contrato local é a que o dx exige | o app não quebra por uma chave que sumiu | checks de contrato de cada repositório; `family-contract` aqui | bloqueante |
| MUD-04 | Paridade do app: uma mudança em `api/` ou `web/` vai para os três dx na mesma rodada | a comparação entre as nuvens é justa | `family-app` (dependências e código, a menos de nomes e comentários) | alerta |
| DOC-01 | Só afirmar o que foi verificado, com os rótulos `verificado no CI`, `verificado localmente`, `não executado em nuvem (v2)`, `planejado` | quem copia o lab confia no que está escrito | `repo-structure` de cada repositório; revisão | bloqueante |
| DOC-02 | Sem autoelogios nem emojis; README com no máximo 250 linhas | docs objetivos | `repo-structure` | bloqueante |
| DOC-03 | Nunca linkar os repositórios v1 (privados e arquivados) | link quebrado e conteúdo antigo | `docs-links` aqui; `family-table` | bloqueante |
| DOC-04 | Todo README (inglês e português) tem a tabela da família com os outros seis repositórios | quem chega por qualquer porta acha o resto | `family-table` | alerta |
| DOC-05 | O ROADMAP segue o formato: campos obrigatórios, status válidos, repositórios conhecidos, dependências que existem, visão geral igual aos itens | o roadmap é conferível, não um texto solto | `roadmap` | bloqueante |
| DOC-06 | Item `feito` tem PRs mesclados na `Evidência`; o `docs/HISTORICO.md` só cita PRs mesclados | o status não fica mais forte que a prova | `family-evidence` | alerta |
| DOC-07 | Os arquivos do padrão v2 existem em cada repositório do lab (README nas duas línguas, AGENTS, FORK, docs de guardrails, harness, sustentação, contrato, runbook, arquitetura, publicação, lab local) | o padrão é o mesmo nos seis | `family-structure` | alerta |
| DOC-08 | Os links do hub para arquivos da família (`blob/main/...`) existem | docs do hub sem link quebrado | `family-links` | alerta |
| CUSTO-01 | Nenhuma ação na nuvem sem o pedido explícito de um humano para aquela ação; toda rodada termina no mesmo dia com destroy, checagem de sobras e `cloud_run_report` | quem paga é quem roda | workflows de nuvem só por `workflow_dispatch` com o environment `lab`; `AGENTS.md` de cada repositório | processo |
| CUSTO-02 | Orçamento e alertas ligados por padrão nos bootstraps; o padrão é o mais barato que funciona; todo item com custo diz quanto e de onde vem o preço | ninguém leva susto na fatura | testes do bootstrap de cada tx; campo `Custo` do ROADMAP | bloqueante |
| AGT-01 | Agentes seguem o `AGENTS.md` do repositório em que trabalham e param antes de: ação em nuvem, mudança de contrato, alargamento de IAM, rede ou RBAC, ignore novo, reescrita de histórico | agentes trabalham rápido; os erros também | `AGENTS.md` dos sete | processo |
| AGT-02 | Uma rodada pesada de lab local por vez (8 GB de Docker para o perfil `full`) | o editor e o Docker travam com duas | `AGENTS.md` dos repositórios do lab | processo |

## Exceções

Uma exceção é sempre explícita, com o motivo e o item do roadmap que acaba com ela:

- Versões diferentes entre os papéis: `FAMILY_VERSION_EXCEPTIONS` em `scripts/harness.sh` (hoje só o
  `KUBECTL_VERSION`, 1.37 nos tx e 1.36 nos dx, até o item S.2 do roadmap). O check imprime cada
  exceção em toda execução.
- Exceções de scanner dos repositórios do lab: `.trivyignore.yaml` com `statement` e `expired_at`.
- Para acrescentar uma: um PR que diz por que, com o item do roadmap que a remove; nunca para deixar
  um check verde.

## Limites

- O estágio `family` é informativo: ele aponta drift, mas não impede um repositório do lab de mesclar
  algo inconsistente. Ele roda nos PRs do hub, em todo push na `main` e toda segunda-feira.
- O `family` confere a `main` de cada repositório (ou checkouts locais com `FAMILY_SOURCE`); um PR
  aberto num repositório do lab só aparece depois do merge.
- A paridade do app compara dependências e o código de `api/src` e `web/src` sem nomes e comentários
  de linha inteira; testes e o smoke (`e2e/`) diferem por desenho (cada nuvem tem a sua borda).
- O hub não prova nada na nuvem: nada da v2 rodou numa nuvem.

## Como verificar

```bash
make tools
HARNESS_STRICT=1 make verify      # SEC, CI, DOC-01 a DOC-05 deste repositório
make family                       # SUP-02, SUP-03, MUD-02 a MUD-04, DOC-04, DOC-06 a DOC-08
scripts/harness.sh list
```
