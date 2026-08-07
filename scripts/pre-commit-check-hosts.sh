#!/usr/bin/env bash
# Git pre-commit hook: Verifies hosts.env is up-to-date with lib/hosts.nix

# Setup:
# ln -sf scripts/pre-commit-check-hosts.sh .git/hooks/
# chmod +x scripts/pre-commit-check-hosts.sh

HOSTS_NIX="lib/hosts.nix"
HOSTS_ENV="hosts.env"

if [ ! -f "$HOSTS_NIX" ] || [ ! -f "$HOSTS_ENV" ]; then
  exit 0
fi

# Extract IPs from lib/hosts.nix
ADGUARD_NIX=$(grep -A1 'adguard-home' "$HOSTS_NIX" | grep -oP '\d+\.\d+\.\d+\.\d+' || true)
RETAIL_NIX=$(grep -A1 'retail-row' "$HOSTS_NIX" | grep -oP '\d+\.\d+\.\d+\.\d+' || true)
LONELY_NIX=$(grep -A1 'lonely-lodge' "$HOSTS_NIX" | grep -oP '\d+\.\d+\.\d+\.\d+' || true)

# Extract IPs from hosts.env
ADGUARD_ENV=$(grep 'ADGUARD_HOME_IP' "$HOSTS_ENV" | cut -d'=' -f2 || true)
RETAIL_ENV=$(grep 'RETAIL_ROW_IP' "$HOSTS_ENV" | cut -d'=' -f2 || true)
LONELY_ENV=$(grep 'LONELY_LODGE_IP' "$HOSTS_ENV" | cut -d'=' -f2 || true)

ERRORS=0

if [ "$ADGUARD_NIX" != "$ADGUARD_ENV" ]; then
  echo "Error: ADGUARD_HOME_IP mismatch between lib/hosts.nix ($ADGUARD_NIX) and hosts.env ($ADGUARD_ENV)"
  ERRORS=1
fi

if [ "$RETAIL_NIX" != "$RETAIL_ENV" ]; then
  echo "Error: RETAIL_ROW_IP mismatch between lib/hosts.nix ($RETAIL_NIX) and hosts.env ($RETAIL_ENV)"
  ERRORS=1
fi

if [ "$LONELY_NIX" != "$LONELY_ENV" ]; then
  echo "Error: LONELY_LODGE_IP mismatch between lib/hosts.nix ($LONELY_NIX) and hosts.env ($LONELY_ENV)"
  ERRORS=1
fi

if [ "$ERRORS" -eq 1 ]; then
  echo "Please sync hosts.env with lib/hosts.nix before committing."
  exit 1
fi
