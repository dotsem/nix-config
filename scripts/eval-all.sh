#!/usr/bin/env bash
# Evaluates every nixosConfiguration without building. Shared by CI and `just check`.
set -uo pipefail

failed=()
for host in $(nix eval --json .#nixosConfigurations --apply builtins.attrNames | jq -r '.[]'); do
  if out=$(nix eval --raw ".#nixosConfigurations.${host}.config.system.build.toplevel.drvPath" 2>&1); then
    echo "ok   ${host}"
  else
    echo "FAIL ${host}"
    printf '%s\n' "$out" | tail -n 25
    failed+=("$host")
    [ -n "${GITHUB_ACTIONS:-}" ] && echo "::error title=eval failed::${host}"
  fi
done

if [ "${#failed[@]}" -gt 0 ]; then
  echo "eval failed for: ${failed[*]}"
  exit 1
fi
