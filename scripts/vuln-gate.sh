#!/usr/bin/env bash
# Gate over a flakevuln findings.json: fails when an active high-severity finding would be
# removed by re-locking the input (a bump fixes it). Findings with no fix in the channel yet
# only warn, so a daily run does not stay red while you wait for a backport.
# usage: vuln-gate.sh <findings.json>   env: MIN_SEVERITY (default 7), FAIL_ON_FINDINGS (default true)
set -euo pipefail

findings="$1"
min="${MIN_SEVERITY:-7}"

jq -e '.scan_rows | type == "array"' "$findings" > /dev/null \
  || { echo "::error title=schema::no scan_rows in ${findings}, flakevuln output format changed?"; exit 1; }

jq -r '(.errors // [])[] | tostring' "$findings" | while read -r e; do echo "::warning title=flakevuln error::${e}"; done

# one tsv line per active high current finding: FIX|WAIT, target, vuln, package, severity
rows=$(jq -r --argjson min "$min" '
  def id: [.target, .vuln_id, .package] | join("|");
  ([.scan_rows[] | select(.pintype == "lock_updated") | id]) as $relocked
  | .scan_rows[]
  | select(.pintype == "current"
      and ((.whitelist | tostring | ascii_downcase) != "true")
      and (((.severity | tostring | tonumber?) // 0) >= $min))
  | [(if (id as $i | $relocked | index($i)) == null then "FIX" else "WAIT" end),
     .target, .vuln_id, .package, .severity] | @tsv' "$findings" | sort -u)

# counted here: the block below runs in a pipeline subshell
fix=$(printf '%s\n' "$rows" | grep -c '^FIX' || true)
{
  echo "### vuln gate (severity >= ${min})"
  echo
  if [ -z "$rows" ]; then
    echo "no active findings"
  else
    echo "| action | target | CVE | package | severity |"
    echo "|---|---|---|---|---|"
    while IFS=$'\t' read -r action target vuln pkg sev; do
      echo "| ${action} | ${target} | ${vuln} | ${pkg} | ${sev} |"
      if [ "$action" = FIX ]; then
        echo "::error title=bump fixes ${vuln}::${target}: ${pkg} (${sev}), run update-flake-lock with which=stable" >&2
      else
        echo "::warning title=no fix in channel yet::${target}: ${vuln} in ${pkg} (${sev})" >&2
      fi
    done <<< "$rows"
  fi
} | tee -a "${GITHUB_STEP_SUMMARY:-/dev/null}"

[ "${FAIL_ON_FINDINGS:-true}" = true ] || exit 0
[ "$fix" -eq 0 ]
