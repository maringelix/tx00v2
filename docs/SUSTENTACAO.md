# Sustentação do tx00v2

## 1. Objetivo e escopo

Manter o hub correto: o roadmap igual ao que aconteceu, os checks da família verdes e as ferramentas
iguais às dos repositórios do lab. A sustentação de cada repositório do lab (imagens, charts,
providers, calendário de Kubernetes e bancos) está no `docs/SUSTENTACAO.md` dele; o calendário com
datas da família inteira está na seção S do [ROADMAP.md](../ROADMAP.md).

## 2. Rotinas

| Quando | O quê | Se falhar |
|---|---|---|
| Toda segunda-feira, 06:00 UTC (automático) | CI agendado: `static` e `family` | seção 3 |
| Todo mês | PRs do Dependabot (actions e pre-commit) | mescle o mesmo bump nos seis repositórios do lab na mesma rodada (`family-actions`) |
| A cada rodada do lab | ROADMAP (status e evidência), `docs/HISTORICO.md` e `CHANGELOG.md` num PR só de documentação | `roadmap` e `family-evidence` dizem o que está inconsistente |
| Todo trimestre (próximo: janeiro de 2027, item S.9) | actionlint, shellcheck, gitleaks e jq com `scripts/update-tool-checksums.sh`, junto com a revisão trimestral dos repositórios do lab | `family-versions` aponta a diferença |

## 3. Quando o `family` fica vermelho

O `family` confere a `main` dos seis repositórios. Vermelho quase sempre é drift lá, não aqui:

| Check | Causa típica | Correção |
|---|---|---|
| `family-ref` | um tx mesclou uma mudança no lab local e o dx ainda fixa o commit anterior | PR no dx que atualiza `deploy/local/tx0Nv2.ref` e passa o `e2e-platform` |
| `family-contract` | um lado do par mudou a versão do contrato e o outro não | os PRs coordenados do contrato (o lado que falta) |
| `family-versions`, `family-digests`, `family-actions` | um bump mesclado num repositório e não nos outros | o mesmo bump nos outros; se a diferença for de propósito, uma exceção com motivo e item do roadmap |
| `family-identical` | um arquivo comum mudou num repositório só | levar a mudança aos outros do mesmo papel |
| `family-app` | uma mudança no app de um dx sem porte | o porte nos outros dois dx (regra de paridade) |
| `family-table`, `family-structure` | um README ou arquivo do padrão mudou | corrigir no repositório do lab |
| `family-links` | um arquivo da família foi renomeado | atualizar o link aqui |
| `family-evidence` | um item foi marcado `feito` antes do merge | voltar o status ou esperar o merge |

Nunca deixe o `family` verde com uma exceção sem motivo: a exceção precisa de um item do roadmap que a
remova ([GUARDRAILS.md](GUARDRAILS.md), "Exceções").

## 4. Procedimentos

### 4.1 Atualizar uma ferramenta

```bash
scripts/update-tool-checksums.sh <ferramenta> <versão>   # versions.env + checksums.txt do upstream
make tools && HARNESS_STRICT=1 make verify && make family
```

actionlint, shellcheck e gitleaks são as mesmas dos repositórios do lab: atualize lá na mesma rodada.

### 4.2 Fechar uma rodada do lab

1. Confira que todos os PRs da rodada foram mesclados com o CI verde.
2. No ROADMAP: status `feito`, `Evidência` com os links, visão geral; itens novos que a rodada achou.
3. No `docs/HISTORICO.md`: a seção da rodada, com os PRs e o que o CI achou.
4. `make static family`, PR, CI verde, merge.

### 4.3 Reaplicar as configurações do repositório

```bash
scripts/repo-guardrails.sh maringelix/tx00v2
gh api repos/maringelix/tx00v2/rulesets --jq '.[].name'
```

No Git Bash do Windows, não exporte `MSYS_NO_PATHCONV=1`: o `gh.exe` precisa do caminho convertido
do `--input` do ruleset.

## 5. Estado atual (2026-10-14)

- Ferramentas: actionlint 1.7.12, shellcheck 0.11.0, gitleaks 8.30.1, jq 1.8.2.
- Exceção registrada: `KUBECTL_VERSION` (1.37 nos tx, 1.36 nos dx), até o item S.2.
- Ruleset: `static` obrigatório; `family` informativo.

## 6. Responsáveis

Bruno Maringeli (`@maringelix`), dono dos sete repositórios. Agentes de IA seguem o
[AGENTS.md](../AGENTS.md) e param antes de qualquer ação em nuvem.
