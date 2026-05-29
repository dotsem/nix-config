#!/usr/bin/env bash
set -euo pipefail

PROG_DIR="/home/sem/prog"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "📂 Creating root development folder: $PROG_DIR..."
mkdir -p "$PROG_DIR"

# 1. Copy the version-controlled master flake.nix into ~/prog/
echo "📝 Copying master flake.nix from nix-config/devshell to $PROG_DIR..."
cp "$REPO_DIR/devshell/flake.nix" "$PROG_DIR/flake.nix"
echo "✅ Master flake.nix successfully deployed to $PROG_DIR."

# 2. Define all required language directories to create
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

# 3. Create subdirectories, map them, inject .envrc, and authorize direnv
echo "🧹 Initializing language directories & .envrc profiles..."
for dir_name in "${!DEVSHELLS[@]}"; do
  target_dir="$PROG_DIR/$dir_name"
  shell_target="${DEVSHELLS[$dir_name]}"
  envrc_path="$target_dir/.envrc"

  # Create folder if it doesn't exist
  if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
    echo "  ✨ Created directory: $target_dir"
  fi

  # Create .envrc mapping
  if [ ! -f "$envrc_path" ]; then
    echo "use flake ../#$shell_target" > "$envrc_path"
    echo "  📝 Created .envrc in $target_dir (mapping to: #$shell_target)"
  else
    echo "  ⚠️ .envrc already exists in $target_dir, skipping."
  fi

  # Automatically authorize the directory with direnv
  if command -v direnv &>/dev/null; then
    direnv allow "$target_dir"
  fi
done

echo "🎉 Development environment deployment completely synchronized and authorized!"
