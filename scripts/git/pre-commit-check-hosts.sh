#!/usr/bin/env bash
# Git pre-commit hook: Verifies hosts.env is up-to-date with lib/hosts.nix

if command -v git &>/dev/null && git rev-parse --show-toplevel &>/dev/null; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi
cd "$REPO_ROOT"

HOSTS_NIX="${HOSTS_NIX:-lib/hosts.nix}"
HOSTS_ENV="${HOSTS_ENV:-hosts.env}"

if [ ! -f "$HOSTS_NIX" ] || [ ! -f "$HOSTS_ENV" ]; then
  exit 0
fi

# Parse lib/hosts.nix dynamically, skipping entries marked with #ch-ignore
declare -A NIX_HOSTS
declare -A EXPECTED_ENV_VARS

while read -r host ip; do
  [[ -z "$host" || -z "$ip" ]] && continue
  env_var="$(echo "$host" | tr '[:lower:]' '[:upper:]' | tr '-' '_')_IP"
  NIX_HOSTS["$env_var"]="$ip"
  EXPECTED_ENV_VARS["$host"]="$env_var"
done < <(awk '
  /#[[:space:]]*[cC][hH]-[iI][gG][nN][oO][rR][eE]/ {
    ignore = 1
  }
  /^[[:space:]]*([a-zA-Z0-9_-]+)[[:space:]]*=[[:space:]]*\{/ {
    match($0, /^[[:space:]]*([a-zA-Z0-9_-]+)/, m)
    curr_host = m[1]
    if ($0 ~ /#[[:space:]]*[cC][hH]-[iI][gG][nN][oO][rR][eE]/) {
      ignore = 1
    }
  }
  curr_host && /ip[[:space:]]*=[[:space:]]*"[0-9.]+"/ {
    match($0, /ip[[:space:]]*=[[:space:]]*"([0-9.]+)"/, m)
    curr_ip = m[1]
  }
  curr_host && /\}/ {
    if (!ignore && curr_ip) {
      print curr_host, curr_ip
    }
    curr_host = ""
    curr_ip = ""
    ignore = 0
  }
' "$HOSTS_NIX")

declare -A ENV_HOSTS
while IFS='=' read -r key val || [ -n "$key" ]; do
  [[ "$key" =~ ^[[:space:]]*# ]] && continue
  [[ -z "$key" ]] && continue

  key=$(echo "$key" | xargs)
  val=$(echo "$val" | xargs)
  val="${val%\"}"
  val="${val#\"}"
  val="${val%\'}"
  val="${val#\'}"

  [[ -n "$key" ]] && ENV_HOSTS["$key"]="$val"
done < "$HOSTS_ENV"

ERRORS=0

for host in "${!EXPECTED_ENV_VARS[@]}"; do
  env_var="${EXPECTED_ENV_VARS[$host]}"
  nix_ip="${NIX_HOSTS[$env_var]}"

  if [[ -z "${ENV_HOSTS[$env_var]+x}" ]]; then
    echo "Error: Missing $env_var in $HOSTS_ENV for host '$host' ($nix_ip)"
    ERRORS=1
  elif [[ "${ENV_HOSTS[$env_var]}" != "$nix_ip" ]]; then
    echo "Error: $env_var mismatch: $HOSTS_NIX has '$nix_ip', $HOSTS_ENV has '${ENV_HOSTS[$env_var]}'"
    ERRORS=1
  fi
done

for key in "${!ENV_HOSTS[@]}"; do
  if [[ "$key" =~ _IP$ ]]; then
    if [[ -z "${NIX_HOSTS[$key]+x}" ]]; then
      echo "Error: Stale variable $key in $HOSTS_ENV (not in $HOSTS_NIX or marked #ch-ignore)"
      ERRORS=1
    fi
  fi
done

if [ "$ERRORS" -eq 1 ]; then
  echo "Please sync $HOSTS_ENV with $HOSTS_NIX (or mark non-deployable hosts with #ch-ignore)."
  exit 1
fi
