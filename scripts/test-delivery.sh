#!/usr/bin/env bash
# Structural fixtures only. Actual merged main commits are checked separately by family-evidence.
set -euo pipefail
# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_cmd jq
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/docs"
cp "$REPO_ROOT/docs/CURRICULUM.md" "$REPO_ROOT/docs/ACCEPTANCE.md" "$WORK/docs/"
jq '.pullRequests |= map(if .number == null then .number = 99 else . end)' \
  "$REPO_ROOT/docs/DELIVERIES.json" >"$WORK/valid.json"
cp "$WORK/valid.json" "$WORK/docs/DELIVERIES.json"
(cd "$WORK" && bash "$REPO_ROOT/scripts/check-delivery.sh") >/dev/null
jq '.pullRequests |= .[:-1]' "$WORK/valid.json" >"$WORK/docs/DELIVERIES.json"
if (cd "$WORK" && bash "$REPO_ROOT/scripts/check-delivery.sh") >/dev/null 2>&1; then
  echo 'incomplete delivery passed'; exit 1
fi
jq '.pullRequests[18].repo="dx01v2" | .pullRequests[18].number=100' "$WORK/valid.json" >"$WORK/docs/DELIVERIES.json"
if (cd "$WORK" && bash "$REPO_ROOT/scripts/check-delivery.sh") >/dev/null 2>&1; then
  echo 'duplicate cloud pair passed'; exit 1
fi
jq '.pullRequests[0].repo="tx01v2" | .pullRequests[0].number=100' "$WORK/valid.json" >"$WORK/docs/DELIVERIES.json"
if (cd "$WORK" && bash "$REPO_ROOT/scripts/check-delivery.sh") >/dev/null 2>&1; then
  echo 'R7 infrastructure entry passed'; exit 1
fi
echo 'delivery fixtures: complete accepted; missing PR, wrong cloud pair and non-app R7 entry refused'
