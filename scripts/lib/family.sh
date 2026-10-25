# shellcheck shell=bash
# The repositories of the v2 family and how the family stage of scripts/harness.sh reaches them.
# Source this file after scripts/lib/common.sh; do not execute it.

# shellcheck disable=SC2034 # used by scripts/harness.sh
FAMILY_TX=(tx01v2 tx02v2 tx03v2)
# shellcheck disable=SC2034
FAMILY_DX=(dx01v2 dx02v2 dx03v2)
FAMILY_LAB=(tx01v2 dx01v2 tx02v2 dx02v2 tx03v2 dx03v2)
FAMILY_HUB=tx00v2
# Learning tracks have their own runtime and validation contract. They are not cloud pairs and
# must never enter the parity, version, standard-file or reciprocal-table checks above.
FAMILY_TRACKS=(tx04v2)
# The docs of the family always link the upstream owner, also in forks (FORK.md).
FAMILY_UPSTREAM=maringelix
# Owner the family stage clones from, and an optional directory with checkouts <dir>/<repo>.
FAMILY_OWNER="${FAMILY_OWNER:-$FAMILY_UPSTREAM}"
FAMILY_SOURCE="${FAMILY_SOURCE:-}"

# family_known REPO -> success for the hub, the six cloud labs and registered learning tracks.
family_known() {
  local r
  for r in "$FAMILY_HUB" "${FAMILY_LAB[@]}" "${FAMILY_TRACKS[@]}"; do
    [[ "$r" == "$1" ]] && return 0
  done
  return 1
}

# family_track REPO -> success only for a registered independent learning track.
family_track() {
  local r
  for r in "${FAMILY_TRACKS[@]}"; do
    [[ "$r" == "$1" ]] && return 0
  done
  return 1
}

# family_pair REPO -> the other half of a cloud pair (tx01v2 <-> dx01v2).
family_pair() {
  case "$1" in
    tx0[1-3]v2) printf 'dx%s\n' "${1#tx}" ;;
    dx0[1-3]v2) printf 'tx%s\n' "${1#dx}" ;;
    *) die "not a cloud-pair repository: $1" ;;
  esac
}

# family_dir REPO -> path of a checkout of REPO: FAMILY_SOURCE/<repo> as it is (any branch), or a
# partial clone (no blobs until needed) of the main branch of FAMILY_OWNER/<repo> under
# $HARNESS_WORK_DIR/family, refreshed once per run of the harness (FAMILY_RUN_ID). The hub uses
# this working tree. Tracks use an explicitly present FAMILY_SOURCE checkout, otherwise their
# public upstream: cloud-only forks do not need to fork an independent learning track.
family_dir() {
  local repo=$1 dir stamp url owner=$FAMILY_OWNER cache="$HARNESS_WORK_DIR/family"
  family_known "$repo" || die "not a family repository: $repo"
  if [[ "$repo" == "$FAMILY_HUB" ]]; then
    printf '%s\n' "$REPO_ROOT"
    return 0
  fi
  if family_track "$repo"; then
    owner=$FAMILY_UPSTREAM
    cache="$HARNESS_WORK_DIR/tracks/$owner"
  fi
  if [[ -n "$FAMILY_SOURCE" ]]; then
    dir="$FAMILY_SOURCE/$repo"
    if [[ -e "$dir" || -L "$dir" ]] || ! family_track "$repo"; then
      [[ "$(git -C "$dir" rev-parse --is-inside-work-tree 2>/dev/null)" == true ]] ||
        die "FAMILY_SOURCE: $dir is not a git checkout"
      [[ -z "$(git -C "$dir" rev-parse --show-prefix)" ]] ||
        die "FAMILY_SOURCE: $dir must be a repository root, not a subdirectory"
      printf '%s\n' "$dir"
      return 0
    fi
  fi
  dir="$cache/$repo"
  stamp="$dir/.git/tx00v2-run"
  url="https://github.com/$owner/$repo.git"
  if [[ ! -d "$dir/.git" ]]; then
    rm -rf "$dir"
    mkdir -p "$cache"
    git clone --quiet --filter=blob:none --branch main "$url" "$dir" >&2 ||
      die "cannot clone $url (the family stage needs the network, or FAMILY_SOURCE=<dir with checkouts>)"
  elif [[ "$(cat "$stamp" 2>/dev/null)" != "${FAMILY_RUN_ID:-}" ]]; then
    git -C "$dir" fetch --quiet origin main >&2 || die "cannot fetch $url"
    git -C "$dir" checkout --quiet -B main origin/main >&2 || die "cannot check out main of $url"
  fi
  printf '%s\n' "${FAMILY_RUN_ID:-}" >"$stamp"
  printf '%s\n' "$dir"
}

# family_check_path REPO PATH -> the same path check used for public documentation links.
# Keep this independent of cloud parity so a track cannot inherit a fictitious cloud contract.
family_check_path() {
  local repo=$1 path=$2 dir
  if [[ -z "$path" || "$path" == /* || "/$path/" == *'/../'* ]]; then
    printf 'invalid repository-relative path: %s\n' "$path" >&2
    return 1
  fi
  dir="$(family_dir "$repo")" || return 1
  [[ -e "$dir/$path" ]] || {
    printf '%s: %s does not exist in the inspected checkout\n' "$repo" "$path" >&2
    return 1
  }
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
