# shellcheck shell=bash
# The repositories of the v2 family and how the family stage of scripts/harness.sh reaches them.
# Source this file after scripts/lib/common.sh; do not execute it.

# shellcheck disable=SC2034 # used by scripts/harness.sh
FAMILY_TX=(tx01v2 tx02v2 tx03v2)
# shellcheck disable=SC2034
FAMILY_DX=(dx01v2 dx02v2 dx03v2)
FAMILY_LAB=(tx01v2 dx01v2 tx02v2 dx02v2 tx03v2 dx03v2)
FAMILY_HUB=tx00v2
# The docs of the family always link the upstream owner, also in forks (FORK.md).
FAMILY_UPSTREAM=maringelix
# Owner the family stage clones from, and an optional directory with checkouts <dir>/<repo>.
FAMILY_OWNER="${FAMILY_OWNER:-$FAMILY_UPSTREAM}"
FAMILY_SOURCE="${FAMILY_SOURCE:-}"

# family_known REPO -> success for the hub and the six lab repositories.
family_known() {
  local r
  for r in "$FAMILY_HUB" "${FAMILY_LAB[@]}"; do
    [[ "$r" == "$1" ]] && return 0
  done
  return 1
}

# family_pair REPO -> the other half of a cloud pair (tx01v2 <-> dx01v2).
family_pair() {
  case "$1" in
    tx0[1-9]v2) printf 'dx%s\n' "${1#tx}" ;;
    dx0[1-9]v2) printf 'tx%s\n' "${1#dx}" ;;
    *) die "not a lab repository: $1" ;;
  esac
}

# family_dir REPO -> path of a checkout of REPO: FAMILY_SOURCE/<repo> as it is (any branch), or a
# partial clone (no blobs until needed) of the main branch of FAMILY_OWNER/<repo> under
# $HARNESS_WORK_DIR/family, refreshed once per run of the harness (FAMILY_RUN_ID).
family_dir() {
  local repo=$1 dir stamp url
  family_known "$repo" || die "not a family repository: $repo"
  if [[ -n "$FAMILY_SOURCE" ]]; then
    dir="$FAMILY_SOURCE/$repo"
    git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 || die "FAMILY_SOURCE: $dir is not a git checkout"
    printf '%s\n' "$dir"
    return 0
  fi
  dir="$HARNESS_WORK_DIR/family/$repo"
  stamp="$dir/.git/tx00v2-run"
  url="https://github.com/$FAMILY_OWNER/$repo.git"
  if [[ ! -d "$dir/.git" ]]; then
    rm -rf "$dir"
    mkdir -p "$HARNESS_WORK_DIR/family"
    git clone --quiet --filter=blob:none --branch main "$url" "$dir" >&2 ||
      die "cannot clone $url (the family stage needs the network, or FAMILY_SOURCE=<dir with checkouts>)"
  elif [[ "$(cat "$stamp" 2>/dev/null)" != "${FAMILY_RUN_ID:-}" ]]; then
    git -C "$dir" fetch --quiet origin main >&2 || die "cannot fetch $url"
    git -C "$dir" checkout --quiet -B main origin/main >&2 || die "cannot check out main of $url"
  fi
  printf '%s\n' "${FAMILY_RUN_ID:-}" >"$stamp"
  printf '%s\n' "$dir"
}

# family_main DIR -> the revision that stands for main in DIR: origin/main when the checkout has it
# (clones, and local checkouts on another branch), else HEAD.
family_main() {
  if git -C "$1" rev-parse --verify -q origin/main >/dev/null; then
    printf 'origin/main\n'
  else
    printf 'HEAD\n'
  fi
}
