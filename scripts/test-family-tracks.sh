#!/usr/bin/env bash
# Offline boundary fixtures: independent tracks must not become fictitious cloud pairs.
set -euo pipefail
# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
# shellcheck source=scripts/lib/family.sh
source "$REPO_ROOT/scripts/lib/family.sh"
require_cmd git

TRACK_TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TRACK_TEST_DIR"' EXIT
HARNESS_WORK_DIR="$TRACK_TEST_DIR/cache"
FAMILY_SOURCE="$TRACK_TEST_DIR/source"
FAMILY_OWNER=example-cloud-owner
FAMILY_RUN_ID=track-fixture
mkdir -p "$FAMILY_SOURCE" "$TRACK_TEST_DIR/template/docs"

expect_failure() {
  if ("$@") >"$TRACK_TEST_DIR/rejected.log" 2>&1; then
    printf 'unexpected acceptance: %s\n' "$*" >&2
    exit 1
  fi
}

family_known tx04v2
family_track tx04v2
expect_failure family_known tx04
expect_failure family_known unknown-repository
expect_failure family_track tx01v2
expect_failure family_pair tx04v2
[[ "$(family_pair tx01v2)" == dx01v2 ]]
[[ "$(family_pair dx03v2)" == tx03v2 ]]
for cloud_repo in "${FAMILY_LAB[@]}" "${FAMILY_TX[@]}" "${FAMILY_DX[@]}"; do
  if family_track "$cloud_repo"; then
    echo "an independent track entered cloud-pair invariants: $cloud_repo" >&2
    exit 1
  fi
done
expect_failure family_dir tx01v2 # Explicit cloud sources remain mandatory.

git init --quiet --initial-branch=main "$TRACK_TEST_DIR/template"
printf 'Fixture documentation\n' >"$TRACK_TEST_DIR/template/docs/lesson.md"
git -C "$TRACK_TEST_DIR/template" add docs/lesson.md
git -C "$TRACK_TEST_DIR/template" -c user.name=Example -c user.email=you@example.com \
  -c commit.gpgsign=false commit --quiet -m 'Fixture lesson'
git clone --quiet "$TRACK_TEST_DIR/template" "$FAMILY_SOURCE/tx04v2"
[[ "$(family_dir tx04v2)" == "$FAMILY_SOURCE/tx04v2" ]]
family_check_path tx04v2 docs/lesson.md
expect_failure family_check_path tx04v2 docs/missing.md
expect_failure family_check_path tx04v2 ../outside.md
expect_failure family_check_path unknown-repository docs/lesson.md

# Git discovers ancestor repositories; a plain folder inside one is not a track checkout.
FAMILY_SOURCE="$TRACK_TEST_DIR/parent-checkout"
git init --quiet --initial-branch=main "$FAMILY_SOURCE"
mkdir -p "$FAMILY_SOURCE/tx04v2/docs"
printf 'Untracked nested content\n' >"$FAMILY_SOURCE/tx04v2/docs/lesson.md"
expect_failure family_dir tx04v2
expect_failure family_check_path tx04v2 docs/lesson.md

# A cloud-only source and a different fork owner must still resolve upstream track links.
# Replace only the network clone with a tiny local fixture; all other Git calls are real.
FAMILY_SOURCE="$TRACK_TEST_DIR/cloud-only"
mkdir -p "$FAMILY_SOURCE" "$TRACK_TEST_DIR/bin"
TRACK_REAL_GIT="$(command -v git)"
TRACK_TEMPLATE="$TRACK_TEST_DIR/template"
TRACK_CLONE_LOG="$TRACK_TEST_DIR/clone-url"
export TRACK_REAL_GIT TRACK_TEMPLATE TRACK_CLONE_LOG
cat >"$TRACK_TEST_DIR/bin/git" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1" == clone ]]; then
  url="${@: -2:1}"
  destination="${!#}"
  printf '%s\n' "$url" >>"$TRACK_CLONE_LOG"
  "$TRACK_REAL_GIT" clone --quiet "$TRACK_TEMPLATE" "$destination"
  "$TRACK_REAL_GIT" -C "$destination" remote set-url origin "$url"
  exit 0
fi
for argument in "$@"; do
  if [[ "$argument" == fetch || "$argument" == ls-remote ]]; then
    echo 'unexpected network operation in offline fixtures' >&2
    exit 1
  fi
done
exec "$TRACK_REAL_GIT" "$@"
STUB
chmod +x "$TRACK_TEST_DIR/bin/git"
export PATH="$TRACK_TEST_DIR/bin:$PATH"
family_check_path tx04v2 docs/lesson.md
family_check_path tx04v2 docs/lesson.md # A second link reuses the same inspected checkout.
expect_failure family_check_path tx04v2 docs/missing.md
[[ "$(cat "$TRACK_CLONE_LOG")" == "https://github.com/$FAMILY_UPSTREAM/tx04v2.git" ]]
[[ "$(family_dir tx04v2)" == "$HARNESS_WORK_DIR/tracks/$FAMILY_UPSTREAM/tx04v2" ]]

echo 'track fixtures: cloud parity preserved; optional upstream/local links accepted; unknown, v1 and missing paths refused'
