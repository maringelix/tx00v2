# Harness do tx00v2

Todo check deste repositório é uma função registrada em `scripts/harness.sh`. Os targets do `make` e
os jobs do CI só chamam esse script. A saída é uma linha `PASS|FAIL|SKIP <check> (<s>s)` por check e
um resumo; qualquer `FAIL` sai com código 1.

## Estágios

| Estágio | Job de CI | Obrigatório | O que precisa |
|---|---|---|---|
| `static` | `static` | sim (ruleset) | as ferramentas de `make tools` e git; nada de rede além do `make tools` |
| `family` | `family` | não (informativo) | rede para clonar a `main` dos seis repositórios, ou `FAMILY_SOURCE` |
| `all` | — | — | `static` + `family` |
| `list` | — | — | só lista os checks |

O `family` não é obrigatório porque depende de seis outros repositórios: um merge lá pode deixá-lo
vermelho sem nenhuma mudança aqui. Ele roda em todo PR, em todo push na `main` e toda segunda-feira
às 06:00 UTC; vermelho é sinal de drift na família ([SUSTENTACAO.md](SUSTENTACAO.md), seção 3).

## Checks do estágio `static`

| Check | Prova | Não prova |
|---|---|---|
| `tool-versions` | as ferramentas no PATH têm as versões de `tools/versions.env` | — |
| `repo-structure` | arquivos obrigatórios; `CLAUDE.md` com `@AGENTS.md` e uma frase; READMEs com até 250 linhas, sem autoelogio e com os rótulos de status; docs sem emoji; LF em todo arquivo; bit de execução dos scripts no índice do git | a qualidade do texto |
| `policy-identifiers` | nenhum ID de conta de 12 dígitos, GUID, e-mail ou IP público fora dos placeholders | identificadores escritos de outro jeito |
| `policy-workflows` | actions fixadas por SHA de 40 caracteres com `# vX.Y.Z`, `permissions: contents: read` no topo, `concurrency`, `timeout-minutes`, `runs-on: ubuntu-24.04`, `persist-credentials: false`, nada de `continue-on-error` nem de engolir erro, nada de `id-token: write`; o job `static` existe e é exigido pelo ruleset; o job `family` existe e não é exigido | que o workflow faz o que deveria |
| `docs-links` | links relativos dos `.md` apontam para arquivos que existem; links para `github.com/maringelix/...` só citam repositórios da família v2; nenhum link para os repositórios v1 | links externos que mudaram (o `family-links` cobre os da família) |
| `roadmap` | todo item do `ROADMAP.md` tem os campos, um status válido, repositórios conhecidos e dependências que existem (itens ou `DP-n`); um item `feito` tem PR na `Evidência` e só depende de itens `feito`; a visão geral lista todos os itens com o mesmo status; todo ID citado existe | que um PR citado foi mesclado (o `family-evidence` cobre) |
| `actionlint` | sintaxe e expressões dos workflows, com shellcheck nos `run:` | — |
| `shellcheck` | todos os scripts com `--severity=style` | — |
| `gitleaks` | nenhum segredo no histórico inteiro (ou no diretório, antes do primeiro commit) | segredos que o gitleaks não reconhece |

## Checks do estágio `family`

| Check | Prova | Não prova |
|---|---|---|
| `family-structure` | cada repositório do lab tem os arquivos do padrão v2, mais os do papel (tx: custos, lições, plataforma, lab local; dx: API, `.nvmrc`, `package.json`, deploy local, e2e da plataforma, o `.ref` do tx) | o conteúdo deles |
| `family-table` | os doze READMEs dos seis (e os dois deste hub) linkam os outros repositórios da família e nenhum v1 | o resto do README |
| `family-contract` | o título do `docs/CONTRATO.md` (versão e data) é igual nos dois lados de cada par; a versão do contrato local que o `deploy-local.sh` do dx exige é a que o tx publica no commit fixado e na `main` | cada chave do contrato (os checks de contrato de cada repositório cobrem) |
| `family-ref` | o `deploy/local/tx0Nv2.ref` de cada dx é um commit da `main` do tx e nenhum commit depois dele mudou o lab local (`platform/local`, `terraform/envs/local`, `scripts/local-lab.sh`, `scripts/local`, `scripts/leftovers-local.sh`); imprime quantos commits o ref está atrás | que o e2e-platform passaria com a `main` do tx |
| `family-versions` | `tools/versions.env`: chaves comuns iguais dentro de cada papel e na família inteira (com as exceções registradas, impressas a cada execução); `platform/versions.env` + `platform/local/versions.env`: chaves comuns iguais nos três tx | versões escritas fora desses arquivos |
| `family-digests` | um digest por imagem `nome:tag` nos seis repositórios; dentro de cada papel, o mesmo conjunto de digests em cada arquivo que os repositórios compartilham (caminhos comparados sem os nomes dos repositórios) | imagens referenciadas sem digest (os checks de cada repositório recusam) |
| `family-identical` | os arquivos da regra SUP-03 do [GUARDRAILS.md](GUARDRAILS.md) são idênticos byte a byte; os três dx têm as mesmas migrações | — |
| `family-app` | os três dx têm as mesmas dependências, `engines` e `workspaces` nos três `package.json` e o mesmo código em `api/src` e `web/src`, a menos dos nomes dos repositórios, de comentários de linha inteira e de linhas em branco | testes e o smoke (`e2e/`), que diferem por desenho |
| `family-actions` | cada action tem um único pin (SHA + tag) nos sete repositórios | — |
| `family-links` | todo link dos docs do hub para `github.com/maringelix/<repo>/blob/main/<caminho>` (ou `tree`) aponta para um caminho que existe | a âncora dentro do arquivo |
| `family-evidence` | todo PR citado na `Evidência` de um item `feito` e no `docs/HISTORICO.md` tem o commit de squash `(#n)` na `main` do repositório | que o PR fez o que o item diz (revisão) |

## Variáveis

| Variável | Efeito |
|---|---|
| `HARNESS_STRICT=1` | todo SKIP vira FAIL (no CI) |
| `HARNESS_VERBOSE=1` | mostra a saída dos checks que passaram |
| `HARNESS_WORK_DIR` | diretório de trabalho: logs e os clones da família (padrão `$TMPDIR/tx00v2-harness`, nunca dentro do repositório) |
| `HARNESS_ONLY=<regex>` | roda só os checks cujo nome casa (depuração local; nunca no CI) |
| `FAMILY_OWNER` | dono dos seis repositórios que o `family` clona (padrão `maringelix`; no CI, `vars.FAMILY_OWNER` ou o dono do repositório) |
| `FAMILY_SOURCE=<dir>` | usa os checkouts `<dir>/<repo>` como estão (qualquer branch), sem rede: serve para conferir um conjunto de PRs antes do merge |

Os clones são parciais (`--filter=blob:none`): o histórico vem inteiro, os arquivos só quando um
check precisa. Eles ficam em `$HARNESS_WORK_DIR/family` e são atualizados uma vez por execução.

## Windows sem WSL

Um container descartável, sem nada escrito na pasta do repositório (útil quando ela está numa pasta
sincronizada, como o OneDrive):

```bash
docker run --rm -v "$PWD:/src:ro" ubuntu:24.04 bash -c '
  apt-get update -qq && apt-get install -y -qq git curl xz-utils make ca-certificates >/dev/null &&
  cp -r /src /work && cd /work && git config --global --add safe.directory "*" &&
  make tools && HARNESS_STRICT=1 make verify && make family'
```

Num clone do Windows os scripts podem perder o bit de execução no índice; o `repo-structure`
avisa e diz o comando (`git update-index --chmod=+x <arquivo>`).

## Como adicionar um check

1. Escreva `check_<nome>` em `scripts/harness.sh`: imprime o que conferiu, `return 1` quando falha e
   `skip "<motivo>"` só quando falta uma pré-condição local (ferramenta, rede).
2. Registre em `register_checks` no estágio certo.
3. Um invariante novo da família roda primeiro contra os repositórios atuais
   (`FAMILY_SOURCE=<dir> make family`): se já for falso, vira um item do roadmap antes de virar check.
4. Documente aqui e no [GUARDRAILS.md](GUARDRAILS.md); `make static family` verde antes do PR.

## Problemas comuns

| Sintoma | Causa | O que fazer |
|---|---|---|
| `SKIP family-*: github.com is not reachable` | sem rede | rode com rede ou `FAMILY_SOURCE` |
| `family-ref` vermelho logo depois de um merge num tx | o dx ainda fixa o commit anterior | o PR do dx que atualiza `deploy/local/tx0Nv2.ref` resolve |
| `family-versions` ou `family-actions` vermelhos no começo do mês | o Dependabot mesclou num repositório e não nos outros | mescle o mesmo bump nos outros |
| `not executable in the git index` | commit feito no Windows | `git update-index --chmod=+x <arquivo>` |
| `tool-versions` vermelho | ferramenta de outra versão no PATH | `make tools` (o harness põe `.tools/bin` na frente do PATH) |
