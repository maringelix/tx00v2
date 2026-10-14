#!/usr/bin/env bash
# tx00v2 harness: every check of the family hub lives here. `make` targets and every CI job only call
# this script (docs/HARNESS.md).
# Usage: scripts/harness.sh <stage>...   stages: static, family, all (= static family), list
#   HARNESS_STRICT=1   (set in CI) turns every SKIP into a FAIL
#   HARNESS_VERBOSE=1  also prints the output of passing checks
#   HARNESS_WORK_DIR   scratch dir for the family clones, logs and caches (default: $TMPDIR/tx00v2-harness)
#   HARNESS_ONLY       extended regex: run only the matching checks (local debugging; never in CI)
#   FAMILY_OWNER       owner the family stage clones the six lab repositories from (default: maringelix)
#   FAMILY_SOURCE      directory with checkouts <dir>/<repo> to check instead of fresh clones of main
# Prints "PASS|FAIL|SKIP <check> (<secs>s)" per check and a summary; exits 1 on any FAIL.
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
# shellcheck source=scripts/lib/tools.sh
source "$REPO_ROOT/scripts/lib/tools.sh"
# shellcheck source=scripts/lib/family.sh
source "$REPO_ROOT/scripts/lib/family.sh"

export PATH="$REPO_ROOT/.tools/bin:$PATH"

HARNESS_STRICT="${HARNESS_STRICT:-0}"
HARNESS_VERBOSE="${HARNESS_VERBOSE:-0}"
HARNESS_WORK_DIR="${HARNESS_WORK_DIR:-${TMPDIR:-/tmp}/tx00v2-harness}"
HARNESS_ONLY="${HARNESS_ONLY:-}"
export HARNESS_WORK_DIR

REQUIRED_FILES=(
  README.md README.pt-BR.md ROADMAP.md AGENTS.md CLAUDE.md CONTRIBUTING.md SECURITY.md CHANGELOG.md LICENSE FORK.md
  .editorconfig .gitattributes .gitignore .pre-commit-config.yaml Makefile
  .github/CODEOWNERS .github/dependabot.yml .github/pull_request_template.md
  .github/ISSUE_TEMPLATE/config.yml .github/ISSUE_TEMPLATE/bug_report.yml .github/ISSUE_TEMPLATE/roadmap_item.yml
  .github/workflows/ci.yml .github/rulesets/main.json
  docs/GUARDRAILS.md docs/HARNESS.md docs/HISTORICO.md docs/SUSTENTACAO.md
  tools/versions.env tools/checksums.txt
  scripts/install-tools.sh scripts/update-tool-checksums.sh scripts/harness.sh scripts/repo-guardrails.sh
  scripts/lib/common.sh scripts/lib/tools.sh scripts/lib/family.sh
)
ROADMAP_STATUSES="feito|em andamento|pendente|bloqueado|proposta"
V1_LINK_RE='github\.com/maringelix/(tx|dx)0[0-9]([^0-9v]|$)'

# Files of the v2 standard every lab repository has (docs/GUARDRAILS.md, DOC-07), plus the ones of
# each role.
FAMILY_FILES_ALL=(
  README.md README.pt-BR.md AGENTS.md CLAUDE.md CONTRIBUTING.md SECURITY.md CHANGELOG.md LICENSE FORK.md
  .editorconfig .gitattributes .gitignore .pre-commit-config.yaml Makefile .devcontainer/devcontainer.json
  .github/CODEOWNERS .github/dependabot.yml .github/pull_request_template.md
  .github/ISSUE_TEMPLATE/config.yml .github/ISSUE_TEMPLATE/bug_report.yml .github/ISSUE_TEMPLATE/cloud_run_report.yml
  .github/workflows/ci.yml .github/rulesets/main.json
  docs/SUSTENTACAO.md docs/GUARDRAILS.md docs/HARNESS.md docs/CONTRATO.md docs/RUNBOOK.md docs/ARQUITETURA.md
  docs/PUBLICACAO.md docs/LAB_LOCAL.md
  tools/versions.env tools/checksums.txt
  scripts/install-tools.sh scripts/update-tool-checksums.sh scripts/harness.sh scripts/repo-guardrails.sh
)
FAMILY_FILES_TX=(
  docs/CUSTOS.md docs/LICOES_APRENDIDAS.md platform/versions.env platform/local/versions.env
  platform/local/install.sh platform/local/check.sh scripts/local-lab.sh scripts/leftovers.sh scripts/leftovers-local.sh
)
FAMILY_FILES_DX=(
  docs/API.md .nvmrc package.json package-lock.json api/package.json web/package.json
  scripts/deploy-local.sh scripts/e2e-platform.sh
)
# Byte-identical files: in the six lab repositories, in the six and the hub, and inside each role
# (docs/GUARDRAILS.md, SUP-03). The hub has its own scripts/repo-guardrails.sh (no environment `lab`).
FAMILY_IDENTICAL_ALL=(scripts/repo-guardrails.sh)
FAMILY_IDENTICAL_HUB=(LICENSE CLAUDE.md .github/CODEOWNERS)
FAMILY_IDENTICAL_TX=(.editorconfig .gitattributes .pre-commit-config.yaml .github/rulesets/main.json scripts/install-tools.sh)
FAMILY_IDENTICAL_DX=(.editorconfig .gitattributes .pre-commit-config.yaml .github/rulesets/main.json
  scripts/update-tool-checksums.sh .nvmrc)
# Tool versions that may differ between the infrastructure and the application repositories, each
# with its reason and the roadmap item that ends the exception.
FAMILY_VERSION_EXCEPTIONS=(
  "KUBECTL_VERSION: tx 1.37 (client for the 1.37 clusters), dx 1.36 (the kind nodes); aligned by ROADMAP S.2"
)
# Paths of the local lab of a tx repository: a dx repository that pins an older commit while one of
# them changed is behind the platform it claims to test (check family-ref).
FAMILY_LOCAL_LAB_PATHS=(platform/local terraform/envs/local scripts/local-lab.sh scripts/local scripts/leftovers-local.sh)

# ---------------------------------------------------------------------------------------------
# Check registry and helpers
# ---------------------------------------------------------------------------------------------

declare -a CHECK_STAGE=() CHECK_NAME=() CHECK_CMD=()
register() {
  CHECK_STAGE+=("$1")
  CHECK_NAME+=("$2")
  CHECK_CMD+=("$3")
}

strict() { [[ "$HARNESS_STRICT" == 1 ]]; }

# skip REASON -> ends the current check as SKIP (FAIL in strict mode). Only for missing preconditions.
# Exit code 77 (the automake SKIP convention) never collides with the tools' own codes.
SKIP_CODE=77
skip() {
  printf 'SKIP_REASON: %s\n' "$*"
  exit "$SKIP_CODE"
}

need() {
  local c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || skip "'$c' not found (run: make tools)"
  done
}

# visible_files -> files git would track (tracked + untracked, minus .gitignore), one per line.
visible_files() {
  git ls-files --cached --others --exclude-standard
}

installed_version() {
  local out=""
  case "$1" in
    actionlint) out="$(actionlint -version 2>/dev/null)" || out="" ;;
    shellcheck) out="$(shellcheck --version 2>/dev/null)" || out="" ;;
    gitleaks) out="$(gitleaks version 2>/dev/null)" || out="" ;;
    jq) out="$(jq --version 2>/dev/null)" || out="" ;;
  esac
  [[ "$out" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]] && printf '%s' "${BASH_REMATCH[1]}"
  return 0
}

# need_family -> skips the check when neither FAMILY_SOURCE nor the network reach the family (the
# network is probed once per run).
need_family() {
  local marker="$HARNESS_WORK_DIR/family/.reachable"
  need git
  [[ -n "$FAMILY_SOURCE" ]] && return 0
  [[ -f "$marker" && "$(cat "$marker")" == "${FAMILY_RUN_ID:-}" ]] && return 0
  git ls-remote --heads "https://github.com/$FAMILY_OWNER/tx01v2.git" >/dev/null 2>&1 ||
    skip "github.com is not reachable (the family stage needs the network, or FAMILY_SOURCE=<dir with checkouts>)"
  mkdir -p "$(dirname "$marker")"
  printf '%s\n' "${FAMILY_RUN_ID:-}" >"$marker"
}

# show_diff FILE_A FILE_B -> prints the first 20 lines of the diff (reporting only, never fails).
show_diff() {
  local out
  if out="$(diff "$1" "$2")"; then
    return 0
  fi
  head -n 20 <<<"$out"
}

# family_dirs -> FD[repo]=checkout for the six lab repositories (clones them on first use).
declare -A FD=()
family_dirs() {
  local r
  need_family
  for r in "${FAMILY_LAB[@]}"; do
    FD[$r]="$(family_dir "$r")"
  done
}

# env_lines REPO FILE -> "REPO KEY VALUE" for every KEY=VALUE line of FILE.
env_lines() {
  sed -nE 's/^([A-Z0-9_]+)=(.*)$/\1 \2/p' "$2" | sed "s/^/$1 /"
}

# compare_keys LABEL "KEY..." < "REPO KEY VALUE" lines -> fails when a key has more than one value,
# except the listed keys, which are reported as exceptions.
compare_keys() {
  awk -v label="$1" -v exc="$2" '
    BEGIN { n = split(exc, e, " "); for (i = 1; i <= n; i++) allowed[e[i]] = 1 }
    {
      k = $2; v = $0; sub(/^[^ ]+ [^ ]+ /, "", v)
      where[k] = where[k] " " $1 "=" v
      if (!((k, v) in seen)) { seen[k, v] = 1; count[k]++ }
      keys[k] = 1
    }
    END {
      for (k in keys) {
        if (count[k] < 2) continue
        if (k in allowed) printf "%s: exception %s:%s\n", label, k, where[k]
        else { printf "%s: %s differs:%s\n", label, k, where[k]; bad = 1 }
      }
      printf "%s: %d keys compared\n", label, length(keys)
      exit bad
    }'
}

# app_normalized FILE -> the file without repository names, full-line comments and blank lines.
app_normalized() {
  sed -E 's/[dt]x0[1-9]v2/XX0Nv2/g' "$1" | grep -vE '^[[:space:]]*(//|/\*|\*)' | grep -vE '^[[:space:]]*$'
}

# local_contract_version < install.sh -> the `version` of the local contract ConfigMap.
local_contract_version() {
  sed -nE 's/^[[:space:]]+version:[[:space:]]*"?([0-9]+)"?[[:space:]]*$/\1/p' | head -n 1
}

# ---------------------------------------------------------------------------------------------
# Static checks (no network, no other repository)
# ---------------------------------------------------------------------------------------------

check_tool_versions() {
  local t want got
  local -a missing=() mismatch=()
  load_versions
  for t in "${TOOLS_ALL[@]}"; do
    want="$(tool_version "$t")"
    if ! command -v "$t" >/dev/null 2>&1; then
      missing+=("$t")
      continue
    fi
    got="$(installed_version "$t")"
    printf '%-12s want %-8s got %-8s %s\n' "$t" "$want" "${got:-?}" "$(command -v "$t")"
    [[ "$got" == "$want" ]] || mismatch+=("$t")
  done
  ((${#missing[@]} == 0)) || skip "missing tools: ${missing[*]} (run: make tools)"
  if ((${#mismatch[@]} > 0)); then
    strict && {
      echo "versions differ from tools/versions.env: ${mismatch[*]}"
      return 1
    }
    skip "versions differ from tools/versions.env: ${mismatch[*]} (run: make tools)"
  fi
}

check_repo_structure() {
  local f rc=0 out
  for f in "${REQUIRED_FILES[@]}"; do
    [[ -f "$f" ]] || {
      echo "missing required file: $f"
      rc=1
    }
  done
  if [[ -f CLAUDE.md ]]; then
    [[ "$(sed -n 1p CLAUDE.md)" == "@AGENTS.md" ]] || {
      echo "CLAUDE.md: the first line must be @AGENTS.md"
      rc=1
    }
    (($(grep -c . CLAUDE.md) == 2)) || {
      echo "CLAUDE.md: must contain exactly @AGENTS.md and one sentence"
      rc=1
    }
  fi
  for f in README.md README.pt-BR.md; do
    [[ -f "$f" ]] || continue
    if (($(wc -l <"$f") > 250)); then
      echo "$f: more than 250 lines"
      rc=1
    fi
    if grep -nE 'production-grade|production-ready|enterprise|best-in-class|world-class' "$f"; then
      echo "$f: no self-ratings"
      rc=1
    fi
  done
  grep -qF 'not run in the cloud (v2)' README.md || {
    echo "README.md: the status tables must use the label 'not run in the cloud (v2)'"
    rc=1
  }
  grep -qF 'não executado em nuvem (v2)' README.pt-BR.md || {
    echo "README.pt-BR.md: the status tables must use the label 'não executado em nuvem (v2)'"
    rc=1
  }
  need git
  # No emojis in the docs (pictographs, dingbats, variation selector).
  local -a md=()
  mapfile -t md < <(visible_files | grep -E '\.md$')
  if ((${#md[@]} > 0)); then
    out="$(LC_ALL=C.UTF-8 grep -nP '[\x{1F000}-\x{1FAFF}\x{2600}-\x{27BF}\x{2B00}-\x{2BFF}\x{FE0F}]' "${md[@]}")" || true
    [[ -z "$out" ]] || {
      printf 'no emojis in the docs:\n%s\n' "$out"
      rc=1
    }
  fi
  while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    if grep -q $'\r' "$f"; then
      echo "CRLF line endings (LF required): $f"
      rc=1
    fi
  done < <(visible_files)
  # Entry-point scripts must keep the executable bit in git (commits from Windows can drop it).
  while IFS= read -r f; do
    [[ "$(git ls-files -s -- "$f" | awk '{ print $1 }')" == 100755 ]] || {
      echo "not executable in the git index (git update-index --chmod=+x $f): $f"
      rc=1
    }
  done < <(git ls-files -- 'scripts/*.sh' | grep -v '^scripts/lib/')
  return "$rc"
}

check_policy_identifiers() {
  local rc=0 out
  local -a files=()
  need git
  grep -qP 'x' <<<"x" 2>/dev/null || skip "grep -P (PCRE) is not available"
  mapfile -t files < <(visible_files | grep -vE '(^|/)checksums\.txt$')
  ((${#files[@]} > 0)) || return 0
  out="$(grep -noP '(?<![0-9A-Za-z])[0-9]{12}(?![0-9A-Za-z])' "${files[@]}" | grep -vE ':(123456789012|000000000000)$')" || true
  [[ -z "$out" ]] || {
    printf 'AWS account IDs and project numbers must be placeholders (123456789012, 000000000000):\n%s\n' "$out"
    rc=1
  }
  out="$(grep -noP '[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}' "${files[@]}" |
    grep -viP '@(example\.(com|org|net)|users\.noreply\.github\.com)$')" || true
  [[ -z "$out" ]] || {
    printf 'e-mail addresses must use example.com/example.org placeholders:\n%s\n' "$out"
    rc=1
  }
  out="$(grep -noP '(?<![0-9.])(?:[0-9]{1,3}\.){3}[0-9]{1,3}(?![0-9.])' "${files[@]}" |
    grep -vP ':(10\.|127\.|169\.254\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|192\.0\.2\.|198\.51\.100\.|203\.0\.113\.|0\.0\.0\.0)')" || true
  [[ -z "$out" ]] || {
    printf 'IP addresses must be private or documentation ranges (RFC 1918 / RFC 5737):\n%s\n' "$out"
    rc=1
  }
  # GUIDs (subscription, tenant, object, client IDs) only as placeholders of one repeated hex digit.
  out="$(grep -noiP '(?<![0-9a-f-])[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}(?![0-9a-f-])' "${files[@]}" |
    grep -viP ':([0-9a-f])\1{7}-\1{4}-\1{4}-\1{4}-\1{12}$')" || true
  [[ -z "$out" ]] || {
    printf 'GUIDs must be placeholders such as 00000000-0000-0000-0000-000000000000:\n%s\n' "$out"
    rc=1
  }
  return "$rc"
}

check_policy_workflows() {
  local f rc=0 out
  local -a files=()
  shopt -s nullglob
  files=(.github/workflows/*.yml .github/workflows/*.yaml)
  ((${#files[@]} > 0)) || {
    echo "no workflows found"
    return 1
  }
  for f in "${files[@]}"; do
    out="$(awk -v file="$f" '
      function err(m) { printf "%s:%d: %s\n", file, NR, m; bad = 1 }
      /^permissions:/ { top_perm = 1; in_top_perm = 1; next }
      in_top_perm && /^  contents: read[[:space:]]*$/ { top_read = 1 }
      in_top_perm && /^[^[:space:]]/ { in_top_perm = 0 }
      /^concurrency:/ { concurrency = 1 }
      /^jobs:/ { in_jobs = 1; next }
      in_jobs && /^  [A-Za-z0-9_-]+:[[:space:]]*$/ { job = $1; sub(/:$/, "", job); jobs[job] = 1; next }
      in_jobs && /^    timeout-minutes:/ { timeout[job] = 1 }
      in_jobs && /^    runs-on: ubuntu-24\.04[[:space:]]*$/ { runs[job] = 1 }
      /^[[:space:]-]*uses:/ {
        ref = $0; sub(/^[[:space:]-]*uses:[[:space:]]*/, "", ref)
        if (ref ~ /^\.\//) next
        if (ref !~ /^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.\/-]+@[0-9a-f]+[[:space:]]+#[[:space:]]+v[0-9]+\.[0-9]+\.[0-9]+[[:space:]]*$/) {
          err("pin actions to a full commit SHA with a trailing # vX.Y.Z comment: " ref)
        } else {
          sha = ref; sub(/^[^@]*@/, "", sha); sub(/[[:space:]].*$/, "", sha)
          if (length(sha) != 40) err("the commit SHA must have 40 characters: " ref)
        }
        if (ref ~ /^actions\/checkout@/) checkouts++
      }
      /persist-credentials: false/ { persist++ }
      /continue-on-error:[[:space:]]*true/ { err("continue-on-error: true is forbidden") }
      /\|\|[[:space:]]*(true|echo|:)([[:space:]]|$)/ { err("never swallow errors (|| true, || echo, || :)") }
      /id-token:[[:space:]]*write/ { err("the hub never requests id-token: write (it talks to no cloud)") }
      END {
        if (!top_perm || !top_read) { printf "%s: top-level permissions must be exactly contents: read\n", file; bad = 1 }
        if (!concurrency) { printf "%s: a top-level concurrency group is required\n", file; bad = 1 }
        for (j in jobs) {
          if (!timeout[j]) { printf "%s: job %s has no timeout-minutes\n", file, j; bad = 1 }
          if (!runs[j]) { printf "%s: job %s must use runs-on: ubuntu-24.04\n", file, j; bad = 1 }
        }
        if (checkouts != persist) { printf "%s: every actions/checkout needs persist-credentials: false\n", file; bad = 1 }
        exit bad
      }' "$f")" || {
      printf '%s\n' "$out"
      rc=1
    }
  done
  grep -qE '^  static:[[:space:]]*$' .github/workflows/ci.yml || {
    echo "ci.yml must keep the stable job id 'static' (required status check)"
    rc=1
  }
  grep -qF '"context": "static"' .github/rulesets/main.json || {
    echo ".github/rulesets/main.json must require the status check 'static'"
    rc=1
  }
  grep -qE '^  family:[[:space:]]*$' .github/workflows/ci.yml || {
    echo "ci.yml must keep the job 'family' (the cross-repo checks)"
    rc=1
  }
  if grep -qF '"context": "family"' .github/rulesets/main.json; then
    echo ".github/rulesets/main.json must not require 'family': it depends on six other repositories"
    rc=1
  fi
  return "$rc"
}

# Relative links resolve; links to GitHub repositories of maringelix name only the v2 family.
check_docs_links() {
  local rc=0 f dir link target path repo checked=0
  local -a files=()
  need git
  while IFS= read -r f; do
    dir="$(dirname "$f")"
    while IFS= read -r link; do
      target="${link#*](}"
      target="${target%)}"
      checked=$((checked + 1))
      case "$target" in
        http://* | https://*)
          if [[ "$target" =~ github\.com/maringelix/([A-Za-z0-9_.-]+) ]]; then
            repo="${BASH_REMATCH[1]}"
            family_known "$repo" || {
              echo "$f: $target links $repo, which is not a repository of the v2 family"
              rc=1
            }
          fi
          ;;
        '#'* | mailto:*) ;;
        *)
          path="${target%%#*}"
          path="${path%%\?*}"
          [[ -n "$path" ]] || continue
          if [[ "$path" == /* ]]; then
            path="${path#/}"
          else
            path="$dir/$path"
          fi
          [[ -e "$path" ]] || {
            echo "$f: broken relative link $target"
            rc=1
          }
          ;;
      esac
    done < <(grep -oE '\]\([^)[:space:]]+\)' "$f")
  done < <(visible_files | grep -E '\.md$')
  mapfile -t files < <(visible_files)
  if grep -nIE "$V1_LINK_RE" "${files[@]}"; then
    echo "links to the v1 repositories (private and archived) are forbidden"
    rc=1
  fi
  echo "$checked markdown links checked"
  return "$rc"
}

# ROADMAP.md: every item has the fields of the format, a valid status, known repositories and
# dependencies; the overview table agrees with the items; every ID mentioned exists.
check_roadmap() {
  [[ -f ROADMAP.md ]] || {
    echo "missing ROADMAP.md"
    return 1
  }
  awk -v statuses="$ROADMAP_STATUSES" -v repos="$FAMILY_HUB ${FAMILY_LAB[*]}" '
    function err(m) { printf "ROADMAP.md:%d: %s\n", NR, m; bad = 1 }
    function trim(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
    function close_item(   i) {
      if (cur == "") return
      for (i = 1; i <= nreq; i++) if (!((cur, req[i]) in field)) { printf "ROADMAP.md: item %s has no field \"%s\"\n", cur, req[i]; bad = 1 }
      if (status[cur] == "feito" && evidence[cur] == 0) { printf "ROADMAP.md: item %s is feito without a PR link in \"Evidência\"\n", cur; bad = 1 }
      cur = ""
    }
    BEGIN {
      ns = split(statuses, s, "|"); for (i = 1; i <= ns; i++) okstatus[s[i]] = 1
      nr = split(repos, r, " "); for (i = 1; i <= nr; i++) okrepo[r[i]] = 1
      nreq = split("Status|Repos|Origem|Dependências|Custo|Entregáveis|Aceite", req, "|")
    }
    {
      line = $0
      while (match(line, /(R[0-9]+|S)\.[0-9]+/)) {
        before = (RSTART > 1) ? substr(line, RSTART - 1, 1) : ""
        after = substr(line, RSTART + RLENGTH, 1)
        if (before !~ /[A-Za-z0-9]/ && after !~ /[A-Za-z0-9]/) mention[substr(line, RSTART, RLENGTH)] = NR
        line = substr(line, RSTART + RLENGTH)
      }
    }
    /^\| *DP-[0-9]+ *\|/ { n = split($0, c, "|"); decision[trim(c[2])] = 1; next }
    /^\| *(R[0-9]+|S)\.[0-9]+ *\|/ {
      n = split($0, c, "|"); id = trim(c[2]); st = c[n - 1]; gsub(/`/, "", st); st = trim(st)
      if (id in tstatus) err("the overview table lists " id " twice")
      tstatus[id] = st
      next
    }
    /^### / {
      close_item()
      if (match($0, /^### (R[0-9]+|S)\.[0-9]+ /)) {
        cur = substr($0, 5, RLENGTH - 5)
        if (cur in seen) err("duplicate item " cur)
        seen[cur] = 1; order[++nitems] = cur; evidence[cur] = 0
      }
      next
    }
    /^## / { close_item(); next }
    cur != "" && /^- [^:]+:/ {
      name = $0; sub(/^- /, "", name); sub(/:.*/, "", name)
      value = $0; sub(/^- [^:]+:[[:space:]]*/, "", value)
      field[cur, name] = 1
      if (name == "Status") {
        st = value; gsub(/`/, "", st); st = trim(st)
        if (!(st in okstatus)) err("item " cur ": invalid status \"" st "\" (" statuses ")")
        status[cur] = st
      } else if (name == "Repos") {
        k = split(value, rr, ","); for (i = 1; i <= k; i++) { x = rr[i]; gsub(/`/, "", x); x = trim(x); if (!(x in okrepo)) err("item " cur ": unknown repository \"" x "\"") }
      } else if (name == "Dependências") {
        deps[cur] = value
      } else if (name == "Evidência") {
        if (value ~ /https:\/\/github\.com\/maringelix\/[a-z0-9]+\/pull\/[0-9]+/) evidence[cur] = 1
      }
    }
    END {
      close_item()
      if (nitems == 0) { print "ROADMAP.md: no items found (### <ID> <title>)"; bad = 1 }
      for (i = 1; i <= nitems; i++) {
        id = order[i]
        if (!(id in tstatus)) { printf "ROADMAP.md: item %s is missing from the overview table\n", id; bad = 1 }
        else if (tstatus[id] != status[id]) { printf "ROADMAP.md: %s is \"%s\" in the overview table but \"%s\" in the item\n", id, tstatus[id], status[id]; bad = 1 }
        v = deps[id]; gsub(/`/, "", v); v = trim(v)
        if (v == "nenhuma") continue
        k = split(v, dd, ",")
        for (j = 1; j <= k; j++) {
          d = trim(dd[j]); sub(/[[:space:]].*$/, "", d)
          if (d ~ /^DP-[0-9]+$/) { if (!(d in decision)) { printf "ROADMAP.md: item %s depends on the unknown decision %s\n", id, d; bad = 1 } }
          else if (!(d in seen)) { printf "ROADMAP.md: item %s depends on the unknown item \"%s\"\n", id, d; bad = 1 }
          else if (status[id] == "feito" && status[d] != "feito") { printf "ROADMAP.md: item %s is feito but depends on %s (%s)\n", id, d, status[d]; bad = 1 }
        }
      }
      for (id in tstatus) if (!(id in seen)) { printf "ROADMAP.md: the overview table lists %s, which has no item\n", id; bad = 1 }
      for (id in mention) if (!(id in seen)) { printf "ROADMAP.md:%d: mentions %s, which is not an item\n", mention[id], id; bad = 1 }
      printf "%d items, %d in the overview table\n", nitems, length(tstatus)
      exit bad
    }' ROADMAP.md
}

check_actionlint() {
  need actionlint shellcheck
  actionlint -shellcheck "$(command -v shellcheck)"
}

check_shellcheck() {
  local -a files=()
  need shellcheck
  mapfile -t files < <(find scripts -type f -name '*.sh' | sort)
  printf 'shellcheck: %s\n' "${files[@]}"
  shellcheck --external-sources --severity=style "${files[@]}"
}

check_gitleaks() {
  need gitleaks git
  if git rev-parse --verify -q HEAD >/dev/null; then
    echo "repository has commits: scanning the full history (gitleaks git)"
    gitleaks git --no-banner --redact --log-level warn .
  else
    echo "no commits yet: scanning the working tree (gitleaks dir)"
    gitleaks dir --no-banner --redact --log-level warn .
  fi
}

# ---------------------------------------------------------------------------------------------
# Family checks (the six lab repositories: clones of main, or FAMILY_SOURCE)
# ---------------------------------------------------------------------------------------------

check_family_structure() {
  local rc=0 r f
  family_dirs
  for r in "${FAMILY_LAB[@]}"; do
    local -a want=("${FAMILY_FILES_ALL[@]}")
    case "$r" in
      tx*) want+=("${FAMILY_FILES_TX[@]}") ;;
      dx*) want+=("${FAMILY_FILES_DX[@]}" "deploy/local/$(family_pair "$r").ref") ;;
    esac
    for f in "${want[@]}"; do
      [[ -e "${FD[$r]}/$f" ]] || {
        echo "$r: missing $f"
        rc=1
      }
    done
    echo "$r: ${#want[@]} files of the v2 standard checked"
  done
  return "$rc"
}

# Every README of the family (both languages) links the other repositories, and none links v1.
check_family_table() {
  local rc=0 r f other d
  family_dirs
  for r in "$FAMILY_HUB" "${FAMILY_LAB[@]}"; do
    if [[ "$r" == "$FAMILY_HUB" ]]; then d="$REPO_ROOT"; else d="${FD[$r]}"; fi
    for f in README.md README.pt-BR.md; do
      for other in "$FAMILY_HUB" "${FAMILY_LAB[@]}"; do
        [[ "$other" == "$r" ]] && continue
        grep -qF "https://github.com/$FAMILY_UPSTREAM/$other)" "$d/$f" || {
          echo "$r/$f: the family table does not link $other"
          rc=1
        }
      done
      if grep -nE "$V1_LINK_RE" "$d/$f"; then
        echo "$r/$f: links a v1 repository"
        rc=1
      fi
    done
  done
  ((rc == 0)) && echo "7 repositories x 2 READMEs: every family table links the other six"
  return "$rc"
}

# Cloud contract: the title of docs/CONTRATO.md (version and date) is the same on both sides of a pair.
# Local contract: the version the dx deploy requires is the one the pinned tx commit and tx main publish.
check_family_contract() {
  local rc=0 n tx dx ref t_title d_title t_ref_v t_main_v d_v
  family_dirs
  for n in 1 2 3; do
    tx="tx0${n}v2"
    dx="dx0${n}v2"
    t_title="$(head -n 1 "${FD[$tx]}/docs/CONTRATO.md")"
    d_title="$(head -n 1 "${FD[$dx]}/docs/CONTRATO.md")"
    if [[ "$t_title" == "$d_title" && "$t_title" =~ vers[^\ ]*o\ [0-9]+ ]]; then
      echo "$tx <-> $dx cloud contract: ${t_title#\# }"
    else
      echo "$tx <-> $dx cloud contract differs: '$t_title' vs '$d_title'"
      rc=1
    fi
    ref="$(tr -d '[:space:]' <"${FD[$dx]}/deploy/local/$tx.ref")"
    [[ "$ref" =~ ^[0-9a-f]{40}$ ]] || {
      echo "$dx/deploy/local/$tx.ref is not a 40-character commit SHA"
      rc=1
      continue
    }
    if ! t_ref_v="$(git -C "${FD[$tx]}" show "$ref:platform/local/install.sh" 2>/dev/null | local_contract_version)"; then
      t_ref_v=""
    fi
    t_main_v="$(local_contract_version <"${FD[$tx]}/platform/local/install.sh")"
    d_v="$(sed -nE 's/^CONTRACT_VERSION=([0-9]+).*$/\1/p' "${FD[$dx]}/scripts/deploy-local.sh" | head -n 1)"
    if [[ -n "$d_v" && "$d_v" == "$t_ref_v" && "$d_v" == "$t_main_v" ]]; then
      echo "$tx <-> $dx local contract: version $d_v (pinned commit ${ref:0:7} and main)"
    else
      echo "$tx <-> $dx local contract: $dx requires '${d_v:-?}', $tx publishes '${t_ref_v:-?}' at ${ref:0:7} and '${t_main_v:-?}' on main"
      rc=1
    fi
  done
  return "$rc"
}

# deploy/local/tx0Nv2.ref of every dx repository is a commit of tx main, and no commit after it
# changed the local lab (otherwise the platform e2e of dx tests an older platform than tx main).
check_family_ref() {
  local rc=0 n tx dx ref main behind touching
  family_dirs
  for n in 1 2 3; do
    tx="tx0${n}v2"
    dx="dx0${n}v2"
    ref="$(tr -d '[:space:]' <"${FD[$dx]}/deploy/local/$tx.ref")"
    if ! git -C "${FD[$tx]}" cat-file -e "$ref^{commit}" 2>/dev/null; then
      echo "$dx pins $tx at '$ref', which is not a commit of $tx"
      rc=1
      continue
    fi
    main="$(family_main "${FD[$tx]}")"
    if ! git -C "${FD[$tx]}" merge-base --is-ancestor "$ref" "$main"; then
      echo "$dx pins $tx at ${ref:0:7}, which is not on the main branch of $tx"
      rc=1
      continue
    fi
    behind="$(git -C "${FD[$tx]}" rev-list --count "$ref..$main")"
    touching="$(git -C "${FD[$tx]}" rev-list --count "$ref..$main" -- "${FAMILY_LOCAL_LAB_PATHS[@]}")"
    echo "$dx pins $tx at ${ref:0:7}: $behind commit(s) behind main, $touching of them change the local lab"
    if ((touching > 0)); then
      git -C "${FD[$tx]}" log --format='  %h %s' "$ref..$main" -- "${FAMILY_LOCAL_LAB_PATHS[@]}"
      echo "$dx must pin the current main of $tx (deploy/local/$tx.ref) and pass its e2e-platform"
      rc=1
    fi
  done
  return "$rc"
}

check_family_versions() {
  local rc=0 r exc
  family_dirs
  exc="$(printf '%s\n' "${FAMILY_VERSION_EXCEPTIONS[@]}" | sed -E 's/:.*$//' | tr '\n' ' ')"
  for r in "${FAMILY_TX[@]}"; do env_lines "$r" "${FD[$r]}/tools/versions.env"; done | compare_keys "tools of the tx repositories" "" || rc=1
  for r in "${FAMILY_DX[@]}"; do env_lines "$r" "${FD[$r]}/tools/versions.env"; done | compare_keys "tools of the dx repositories" "" || rc=1
  {
    env_lines "$FAMILY_HUB" "$REPO_ROOT/tools/versions.env"
    for r in "${FAMILY_LAB[@]}"; do env_lines "$r" "${FD[$r]}/tools/versions.env"; done
  } | compare_keys "tools of the family" "$exc" || rc=1
  printf 'exception: %s\n' "${FAMILY_VERSION_EXCEPTIONS[@]}"
  for r in "${FAMILY_TX[@]}"; do
    env_lines "$r" "${FD[$r]}/platform/versions.env"
    env_lines "$r" "${FD[$r]}/platform/local/versions.env"
  done | compare_keys "charts and versions of the tx platforms" "" || rc=1
  return "$rc"
}

# Image digests: one digest per image name:tag in the six repositories, and the same set of digests in
# the files the repositories of a role share (paths compared with the repository names normalized).
check_family_digests() {
  local rc=0 r
  family_dirs
  for r in "${FAMILY_LAB[@]}"; do
    git -C "${FD[$r]}" grep -hoIE '[a-z][a-z0-9._/-]*(:[A-Za-z0-9._-]+)?@sha256:[0-9a-f]{64}' -- . \
      ':(exclude)*package-lock.json' | sort -u | sed "s|^|$r |"
  done | awk '
    { split($2, a, "@"); key = a[1]; if (key ~ /^v?[0-9]/) next
      where[key] = where[key] " " $1 "=" substr(a[2], 8, 12)
      if (!((key, a[2]) in seen)) { seen[key, a[2]] = 1; count[key]++ } }
    END {
      for (k in count) { images++; if (count[k] > 1) { printf "image %s has more than one digest:%s\n", k, where[k]; bad = 1 } }
      printf "%d image references compared across the six repositories\n", images
      exit bad
    }' || rc=1
  for r in "${FAMILY_LAB[@]}"; do
    git -C "${FD[$r]}" grep -oIE 'sha256:[0-9a-f]{64}' -- . ':(exclude)*package-lock.json' ':(exclude)*.terraform.lock.hcl' \
      ':(exclude)tools/checksums.txt' | sed -E "s/[dt]x0[1-9]v2/XX0Nv2/g; s|^|$r |"
  done | awk '
    {
      repo = $1; rest = $2; i = index(rest, ":"); path = substr(rest, 1, i - 1); digest = substr(rest, i + 1)
      role = substr(repo, 1, 2)
      if (!((repo, path, digest) in seen)) { seen[repo, path, digest] = 1; set[repo, path] = set[repo, path] " " digest }
      repos[role, path] = repos[role, path] " " repo; paths[role, path] = 1
    }
    END {
      for (rp in paths) {
        split(rp, x, SUBSEP); role = x[1]; path = x[2]
        n = split(repos[rp], rr, " "); delete u; m = 0
        for (i = 1; i <= n; i++) if (!(rr[i] in u)) { u[rr[i]] = 1; list[++m] = rr[i] }
        if (m < 2) continue
        shared++
        for (i = 2; i <= m; i++) {
          if (sorted(set[list[1], path]) != sorted(set[list[i], path])) {
            printf "%s files %s: the digests of %s differ from %s\n", role, path, list[i], list[1]; bad = 1
          }
        }
      }
      printf "%d shared files with digests compared inside each role\n", shared
      exit bad
    }
    function sorted(s,   a, n, i, j, t, out) {
      n = split(s, a, " ")
      for (i = 2; i <= n; i++) { t = a[i]; for (j = i - 1; j >= 1 && a[j] > t; j--) a[j + 1] = a[j]; a[j + 1] = t }
      out = ""; for (i = 1; i <= n; i++) out = out " " a[i]
      return out
    }' || rc=1
  return "$rc"
}

check_family_identical() {
  local rc=0 f r first sum want
  local -a group=()
  family_dirs
  # identical FILE REPO... -> fails when the copies of FILE differ (the hub is "tx00v2" = this checkout).
  identical() {
    local file=$1 path
    shift
    first="" want=""
    for r in "$@"; do
      if [[ "$r" == "$FAMILY_HUB" ]]; then path="$REPO_ROOT/$file"; else path="${FD[$r]}/$file"; fi
      [[ -f "$path" ]] || {
        echo "$r: missing $file"
        return 1
      }
      sum="$(sha256_of "$path")"
      if [[ -z "$first" ]]; then
        first=$r
        want=$sum
      elif [[ "$sum" != "$want" ]]; then
        echo "$file of $r differs from the one of $first"
        return 1
      fi
    done
  }
  for f in "${FAMILY_IDENTICAL_ALL[@]}"; do identical "$f" "${FAMILY_LAB[@]}" || rc=1; done
  group=("$FAMILY_HUB" "${FAMILY_LAB[@]}")
  for f in "${FAMILY_IDENTICAL_HUB[@]}"; do identical "$f" "${group[@]}" || rc=1; done
  for f in "${FAMILY_IDENTICAL_TX[@]}"; do identical "$f" "${FAMILY_TX[@]}" || rc=1; done
  for f in "${FAMILY_IDENTICAL_DX[@]}"; do identical "$f" "${FAMILY_DX[@]}" || rc=1; done
  # The migrations of the app: the same files in the three dx repositories.
  while IFS= read -r f; do
    identical "$f" "${FAMILY_DX[@]}" || rc=1
  done < <(git -C "${FD[dx01v2]}" ls-files -- api/migrations)
  for r in "${FAMILY_DX[@]}"; do
    git -C "${FD[$r]}" ls-files -- api/migrations | sha256sum | sed "s/ .*/ $r/"
  done | awk '{ c[$1]++ } END { if (length(c) != 1) { print "the dx repositories have different lists of migrations"; exit 1 } }' || rc=1
  ((rc == 0)) && echo "$((${#FAMILY_IDENTICAL_ALL[@]} + ${#FAMILY_IDENTICAL_HUB[@]} + ${#FAMILY_IDENTICAL_TX[@]} + ${#FAMILY_IDENTICAL_DX[@]})) files and the migrations are identical where they must be"
  return "$rc"
}

# The same application in the three dx repositories: dependencies and engines of every package.json,
# and api/src + web/src without repository names and comments.
check_family_app() {
  local rc=0 f r sum want first
  need jq
  family_dirs
  for f in package.json api/package.json web/package.json; do
    first="" want=""
    for r in "${FAMILY_DX[@]}"; do
      sum="$(jq -S '{dependencies, devDependencies, optionalDependencies, peerDependencies, overrides, engines, workspaces}' \
        "${FD[$r]}/$f" | sha256sum | awk '{ print $1 }')"
      if [[ -z "$first" ]]; then
        first=$r
        want=$sum
      elif [[ "$sum" != "$want" ]]; then
        echo "$f: the dependencies of $r differ from the ones of $first"
        show_diff <(jq -S '{dependencies, devDependencies, engines}' "${FD[$first]}/$f") \
          <(jq -S '{dependencies, devDependencies, engines}' "${FD[$r]}/$f")
        rc=1
      fi
    done
  done
  for r in "${FAMILY_DX[@]}"; do
    git -C "${FD[$r]}" ls-files -- api/src web/src | sort >"$HARNESS_WORK_DIR/app-files-$r.txt"
  done
  for r in dx02v2 dx03v2; do
    if ! cmp -s "$HARNESS_WORK_DIR/app-files-dx01v2.txt" "$HARNESS_WORK_DIR/app-files-$r.txt"; then
      echo "api/src and web/src of $r do not have the files of dx01v2:"
      show_diff "$HARNESS_WORK_DIR/app-files-dx01v2.txt" "$HARNESS_WORK_DIR/app-files-$r.txt"
      rc=1
    fi
  done
  while IFS= read -r f; do
    for r in dx02v2 dx03v2; do
      [[ -f "${FD[$r]}/$f" ]] || continue
      if ! cmp -s <(app_normalized "${FD[dx01v2]}/$f") <(app_normalized "${FD[$r]}/$f"); then
        echo "$f of $r differs from dx01v2 beyond names and comments:"
        show_diff <(app_normalized "${FD[dx01v2]}/$f") <(app_normalized "${FD[$r]}/$f")
        rc=1
      fi
    done
  done <"$HARNESS_WORK_DIR/app-files-dx01v2.txt"
  ((rc == 0)) && echo "3 package.json files and $(wc -l <"$HARNESS_WORK_DIR/app-files-dx01v2.txt") source files are the same app in the three dx repositories"
  return "$rc"
}

# One pin (commit SHA + tag comment) per action in the workflows of the hub and the six repositories.
check_family_actions() {
  local r d
  family_dirs
  for r in "$FAMILY_HUB" "${FAMILY_LAB[@]}"; do
    if [[ "$r" == "$FAMILY_HUB" ]]; then d="$REPO_ROOT"; else d="${FD[$r]}"; fi
    grep -hoE 'uses:[[:space:]]*[^[:space:]]+@[0-9a-f]{40}[[:space:]]+#[[:space:]]+v[0-9][0-9.]*' "$d"/.github/workflows/*.yml |
      sed -E 's/uses:[[:space:]]*//' | sed "s|^|$r |"
  done | awk '
    { split($2, a, "@"); act = a[1]; pin = a[2] " " $4
      if (!((act, pin) in seen)) { seen[act, pin] = 1; n[act]++; pins[act] = pins[act] " " substr(a[2], 1, 7) "(" $4 ")" }
      users[act] = users[act] " " $1 }
    END {
      for (k in n) { actions++; if (n[k] > 1) { printf "%s has %d pins:%s (used by%s)\n", k, n[k], pins[k], users[k]; bad = 1 } }
      printf "%d actions, one pin each across the family\n", actions
      exit bad
    }'
}

# Links of the hub docs to files of the family (blob|tree/main/<path>) point to existing paths.
check_family_links() {
  local rc=0 link repo path d checked=0
  local -a md=()
  family_dirs
  mapfile -t md < <(visible_files | grep -E '\.md$')
  while IFS= read -r link; do
    [[ "$link" =~ ^https://github\.com/maringelix/([a-z0-9]+)/(blob|tree)/main/([^#?]*) ]] || continue
    repo="${BASH_REMATCH[1]}"
    path="${BASH_REMATCH[3]}"
    path="${path%/}"
    checked=$((checked + 1))
    if [[ "$repo" == "$FAMILY_HUB" ]]; then d="$REPO_ROOT"; else d="${FD[$repo]:-}"; fi
    [[ -n "$d" ]] || {
      echo "$link: $repo is not a repository of the family"
      rc=1
      continue
    }
    [[ -e "$d/$path" ]] || {
      echo "$link: $path does not exist on main of $repo"
      rc=1
    }
  done < <(grep -ohE 'https://github\.com/maringelix/[a-z0-9]+/(blob|tree)/main/[^)[:space:]>`]+' "${md[@]}" | sort -u)
  echo "$checked links to files of the family checked"
  return "$rc"
}

# Evidence: the PR links of the done items of ROADMAP.md and of docs/HISTORICO.md are merged, that
# is, main of the repository has its squash commit "<title> (#n)".
check_family_evidence() {
  local rc=0 repo n d log checked=0
  [[ -f ROADMAP.md && -f docs/HISTORICO.md ]] || {
    echo "missing ROADMAP.md or docs/HISTORICO.md"
    return 1
  }
  family_dirs
  while read -r repo n; do
    checked=$((checked + 1))
    family_known "$repo" || {
      echo "unknown repository in a PR link: $repo"
      rc=1
      continue
    }
    if [[ "$repo" == "$FAMILY_HUB" ]]; then d="$REPO_ROOT"; else d="${FD[$repo]}"; fi
    log="$HARNESS_WORK_DIR/subjects-$repo.txt"
    [[ -f "$log" && "$(head -n 1 "$log")" == "${FAMILY_RUN_ID:-}" ]] || {
      printf '%s\n' "${FAMILY_RUN_ID:-}" >"$log"
      git -C "$d" log --format=%s "$(family_main "$d")" >>"$log"
    }
    grep -qE "\(#$n\)\$" "$log" || {
      echo "$repo#$n: main has no squash commit '(#$n)' (not merged yet?)"
      rc=1
    }
  done < <(
    {
      awk '/^### (R[0-9]+|S)\.[0-9]+ / { done = 0; next }
        /^- Status: `feito`/ { done = 1; next }
        done && /^- Evidência:/ { print }
        /^## / { done = 0 }' ROADMAP.md
      cat docs/HISTORICO.md
    } | grep -oE 'https://github\.com/maringelix/[a-z0-9]+/pull/[0-9]+' |
      sed -E 's|https://github\.com/maringelix/([a-z0-9]+)/pull/([0-9]+)|\1 \2|' | sort -u
  )
  echo "$checked merged pull requests checked (done items of ROADMAP.md and docs/HISTORICO.md)"
  return "$rc"
}

register_checks() {
  register static tool-versions check_tool_versions
  register static repo-structure check_repo_structure
  register static policy-identifiers check_policy_identifiers
  register static policy-workflows check_policy_workflows
  register static docs-links check_docs_links
  register static roadmap check_roadmap
  register static actionlint check_actionlint
  register static shellcheck check_shellcheck
  register static gitleaks check_gitleaks
  register family family-structure check_family_structure
  register family family-table check_family_table
  register family family-contract check_family_contract
  register family family-ref check_family_ref
  register family family-versions check_family_versions
  register family family-digests check_family_digests
  register family family-identical check_family_identical
  register family family-app check_family_app
  register family family-actions check_family_actions
  register family family-links check_family_links
  register family family-evidence check_family_evidence
}

# ---------------------------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------------------------

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
declare -a FAILED=()

run_check() {
  local name=$1 cmd=$2 log rc start secs status reason="" lines
  local -a parts=()
  read -ra parts <<<"$cmd"
  log="$HARNESS_WORK_DIR/logs/${name//[^A-Za-z0-9._-]/_}.log"
  start=$SECONDS
  set +e
  (
    set -euo pipefail
    cd "$REPO_ROOT"
    "${parts[@]}"
  ) >"$log" 2>&1
  rc=$?
  set -e
  secs=$((SECONDS - start))
  case "$rc" in
    0) status=PASS ;;
    "$SKIP_CODE")
      reason="$(sed -n 's/^SKIP_REASON: //p' "$log" | tail -n 1)"
      if strict; then
        status=FAIL
        reason="$reason (SKIP is not allowed with HARNESS_STRICT=1)"
      else
        status=SKIP
      fi
      ;;
    *) status=FAIL ;;
  esac
  printf '%s %s (%ss)%s\n' "$status" "$name" "$secs" "${reason:+ - $reason}"
  case "$status" in
    PASS) PASS_COUNT=$((PASS_COUNT + 1)) ;;
    SKIP) SKIP_COUNT=$((SKIP_COUNT + 1)) ;;
    FAIL)
      FAIL_COUNT=$((FAIL_COUNT + 1))
      FAILED+=("$name")
      ;;
  esac
  if [[ "$status" == FAIL || "$HARNESS_VERBOSE" == 1 ]]; then
    lines="$(wc -l <"$log")"
    if ((lines > 400)); then
      echo "    ... last 400 of $lines lines (full log: $log)"
    fi
    tail -n 400 "$log" | sed 's/^/    /'
  fi
}

list_checks() {
  local i
  echo "stages:"
  echo "  static  structure, identifiers, workflow policy, links, roadmap format, actionlint, shellcheck, gitleaks"
  echo "  family  the six lab repositories: standard files, family tables, contract, refs, versions, digests,"
  echo "          identical files, app parity, action pins, links and evidence of the hub docs"
  echo "  all     static + family"
  echo "checks:"
  for i in "${!CHECK_NAME[@]}"; do
    printf '  %-7s %s\n' "${CHECK_STAGE[$i]}" "${CHECK_NAME[$i]}"
  done
}

usage() {
  echo "usage: $0 <stage>...   (stages: static, family, all, list)" >&2
  exit 2
}

main() {
  local arg stage i start_all=$SECONDS
  local -a stages=()
  declare -A seen=()
  (($# > 0)) || usage
  register_checks
  for arg in "$@"; do
    case "$arg" in
      static | family) stages+=("$arg") ;;
      all) stages+=(static family) ;;
      list)
        list_checks
        return 0
        ;;
      *) usage ;;
    esac
  done
  mkdir -p "$HARNESS_WORK_DIR/logs"
  FAMILY_RUN_ID="$$-$(date -u +%s)"
  export FAMILY_RUN_ID
  echo "harness: stages=${stages[*]} strict=$HARNESS_STRICT work_dir=$HARNESS_WORK_DIR${HARNESS_ONLY:+ only=$HARNESS_ONLY}${FAMILY_SOURCE:+ family_source=$FAMILY_SOURCE}"
  for stage in "${stages[@]}"; do
    for i in "${!CHECK_NAME[@]}"; do
      [[ "${CHECK_STAGE[$i]}" == "$stage" && -z "${seen[${CHECK_NAME[$i]}]:-}" ]] || continue
      [[ -z "$HARNESS_ONLY" || "${CHECK_NAME[$i]}" =~ $HARNESS_ONLY ]] || continue
      seen[${CHECK_NAME[$i]}]=1
      run_check "${CHECK_NAME[$i]}" "${CHECK_CMD[$i]}"
    done
  done
  echo "summary: $((PASS_COUNT + FAIL_COUNT + SKIP_COUNT)) checks, $PASS_COUNT PASS, $FAIL_COUNT FAIL, $SKIP_COUNT SKIP ($((SECONDS - start_all))s, strict=$HARNESS_STRICT)"
  if ((PASS_COUNT + FAIL_COUNT + SKIP_COUNT == 0)); then
    echo "no check matched HARNESS_ONLY='$HARNESS_ONLY'"
    return 1
  fi
  if ((FAIL_COUNT > 0)); then
    echo "failed: ${FAILED[*]}"
    return 1
  fi
}

main "$@"
