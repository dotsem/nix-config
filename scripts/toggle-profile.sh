#!/usr/bin/env bash
set -euo pipefail

# toggle-profile.sh: updates nixos installation package profile state
# usage: ./toggle-profile.sh [enable|disable]

ACTION="${1:-}"

if [[ "$ACTION" != "enable" && "$ACTION" != "disable" ]]; then
  echo "usage: $0 [enable|disable]" >&2
  exit 1
fi

STATE_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common/packages/profile-state.nix"

if [[ "$ACTION" == "enable" ]]; then
  echo "enabling full package profile..."
  cat <<EOF > "$STATE_FILE"
{
  custom.desktop.fullProfile.enable = true;
}
EOF
else
  echo "disabling full package profile (essential only)..."
  cat <<EOF > "$STATE_FILE"
{
  custom.desktop.fullProfile.enable = false;
}
EOF
fi

# stage changes in git so nix flake is aware of the state change
git add "$STATE_FILE"
echo "profile successfully updated and staged in git."
