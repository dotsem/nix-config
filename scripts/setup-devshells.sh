#!/usr/bin/env bash
set -euo pipefail

PROG_DIR="/home/sem/prog"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
DEVSHELL_DIR="$REPO_DIR/devshell"

echo "📂 Creating root development folder: $PROG_DIR..."
mkdir -p "$PROG_DIR"

# clean up legacy redundant flake copies in ~/prog
rm -f "$PROG_DIR/flake.nix" "$PROG_DIR/flake.lock"

# 1. Define all required language directories to create
declare -A DEVSHELLS
DEVSHELLS["c"]="cpp"
DEVSHELLS["c++"]="cpp"
DEVSHELLS["csharp"]="csharp"
DEVSHELLS["di"]="shell" # default placeholder
DEVSHELLS["flutter"]="flutter"
DEVSHELLS["go"]="go"
DEVSHELLS["java"]="java"
DEVSHELLS["misc"]="shell"
DEVSHELLS["php"]="php"
DEVSHELLS["python"]="python"
DEVSHELLS["rust"]="rust"
DEVSHELLS["shell"]="shell"
DEVSHELLS["skill"]="shell"
DEVSHELLS["web"]="web"

# 2. Create subdirectories, map them, inject .envrc, and authorize direnv
echo "🧹 Initializing language directories & .envrc profiles..."
for dir_name in "${!DEVSHELLS[@]}"; do
  target_dir="$PROG_DIR/$dir_name"
  shell_target="${DEVSHELLS[$dir_name]}"
  envrc_path="$target_dir/.envrc"

  if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
    echo "  ✨ Created directory: $target_dir"
  fi

  # direct .envrc mapping to master devshell flake
  echo "use flake $DEVSHELL_DIR#$shell_target" > "$envrc_path"
  echo "  📝 Configured .envrc in $target_dir -> devshell#$shell_target"

  if command -v direnv &>/dev/null; then
    direnv allow "$target_dir"
  fi
done

echo "🎉 Development environment deployment completely synchronized and authorized!"
