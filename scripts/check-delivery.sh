#!/usr/bin/env bash
# The 21 implementation PRs precede the single hub closure PR. Main evidence is checked by family-evidence.
set -euo pipefail
# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
require_cmd jq
jq -e '
  .decision == "DEC-13" and .plannedPullRequests == 22 and .hubClosurePullRequests == 1 and
  (.pullRequests | length == 21) and
  ([.pullRequests[] | .repo + "#" + (.number|tostring)] | unique | length == 21) and
  (.pullRequests | all(.[]; (.number | type == "number" and . > 0 and floor == .) and
    (.repo | test("^[dt]x0[123]v2$")))) and
  ([.pullRequests[] | select(.round=="R7")] | length == 3) and
  ([.pullRequests[] | select(.round=="R8")] | length == 6) and
  ([.pullRequests[] | select(.round=="R9")] | length == 6) and
  ([.pullRequests[] | select(.round=="R10")] | length == 6)
' docs/ENTREGAS.json >/dev/null
jq -e '[.pullRequests[] | select(.round=="R7") | .repo] | sort ==
  (["dx01v2","dx02v2","dx03v2"] | sort)' docs/ENTREGAS.json >/dev/null
for round in R8 R9 R10; do
  jq -e --arg round "$round" '
    [.pullRequests[] | select(.round==$round) | .repo] | sort ==
    (["tx01v2","dx01v2","tx02v2","dx02v2","tx03v2","dx03v2"] | sort)
  ' docs/ENTREGAS.json >/dev/null
done
for file in docs/CURRICULO.md docs/ACEITE_FINAL.md; do
  [[ -s "$file" ]] || { echo "missing acceptance material: $file"; exit 1; }
done
echo '21 implementation PR entries + 1 hub closure = 22; each round and cloud pair represented'
