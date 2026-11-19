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

# packages that only exist in the build closure (the scan targets the .drv), never run on a host
denylist='["gcc","binutils","bison","cargo","ShellCheck","wheel","setuptools","rubygems","sassc","alex","Diff","bytes","stringbuilder","async"]'
# a single scanner is mostly version-match noise: nixpkgs backports fixes without bumping versions
min_scanners="${MIN_SCANNERS:-2}"

# one tsv line per active high current finding: FIX|WAIT, target, vuln, package, severity
# FIX needs the re-locked scan to have actually run; when the lock is already current it is
# skipped and nothing is in $relocked, which would otherwise mark every finding FIX
jqdefs='
  def id: [.target, .vuln_id, .package] | join("|");
  def active: .pintype == "current"
    and ((.whitelist | tostring | ascii_downcase) != "true")
    and (((.severity | tostring | tonumber?) // 0) >= $min);
  def denied: .package as $p | $deny | index($p) != null;
  def lowconf: ((.sum | tostring | tonumber?) // 0) < $scanners;'
jqargs=(--argjson min "$min" --argjson deny "$denylist" --argjson scanners "$min_scanners")

rows=$(jq -r "${jqargs[@]}" "$jqdefs"'
  (any((.completed_scans // [])[]; .[2] == "lock_updated")) as $relock_ran
  | ([.scan_rows[] | select(.pintype == "lock_updated") | id]) as $relocked
  | .scan_rows[]
  | select(active and (denied | not) and (lowconf | not))
  | [(if $relock_ran and (id as $i | $relocked | index($i)) == null then "FIX" else "WAIT" end),
     .target, .vuln_id, .package, .severity] | @tsv' "$findings" | sort -u)

# what the filters hid, so a drop never goes unnoticed; build-only wins when both apply
suppressed=$(jq -r "${jqargs[@]}" "$jqdefs"'
  [.scan_rows[] | select(active and (denied or lowconf))
   | {k: id, p: .package, r: (if denied then "build-only" else "single-scanner" end)}]
  | unique_by(.k) as $u
  | [($u | map(select(.r == "single-scanner")) | length | select(. > 0) | "\(.) single-scanner (sum < '"$min_scanners"')"),
     ($u | map(select(.r == "build-only")) | group_by(.p)
        | map("\(.[0].p) \(length)") | select(length > 0)
        | "\(map(split(" ")[1] | tonumber) | add) build-only (\(join(", ")))")]
  | join("; ")' "$findings")

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
  if [ -n "$suppressed" ]; then
    echo
    echo "suppressed (not gated): ${suppressed}"
    echo "::notice title=vuln gate suppressed::${suppressed}" >&2
  fi
} | tee -a "${GITHUB_STEP_SUMMARY:-/dev/null}"

[ "${FAIL_ON_FINDINGS:-true}" = true ] || exit 0
[ "$fix" -eq 0 ]
