#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
nix run nixpkgs#nixos-rebuild -- switch --flake "$REPO_ROOT#retail-row" --target-host sem@192.168.10.102 --ask-sudo-password