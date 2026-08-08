#!/usr/bin/env bash
set -euo pipefail

# automatic encryption of unencrypted secret files using sops and age
if command -v git &>/dev/null && git rev-parse --show-toplevel &>/dev/null; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi
cd "$REPO_ROOT"

# verify sops is installed
if ! command -v sops &>/dev/null; then
  # only fail if unencrypted secret candidates exist
  HAS_SOPS=false
else
  HAS_SOPS=true
fi

# collect candidate secret files from working tree and staged index
declare -A SECRET_FILES

# 1. match files configured in .sops.yaml creation rules
if [[ -f "$REPO_ROOT/.sops.yaml" ]]; then
  while IFS= read -r regex; do
    [[ -z "$regex" ]] && continue
    # clean regex for find/grep matching
    clean_pattern=$(echo "$regex" | sed 's/\\//g' | sed 's/\$$//' | sed 's/^\^//')
    while IFS= read -r match_file; do
      [[ -n "$match_file" && -f "$match_file" ]] && SECRET_FILES["$match_file"]=1
    done < <(find . -not -path '*/.*' -type f | grep -E "$regex" 2>/dev/null || true)
  done < <(grep -E 'path_regex:' "$REPO_ROOT/.sops.yaml" | awk '{print $2}' || true)
fi

# 2. find common secret file naming conventions
while IFS= read -r found_file; do
  [[ -n "$found_file" && -f "$found_file" ]] && SECRET_FILES["$found_file"]=1
done < <(find . -not -path '*/.*' -not -path './.venv/*' -type f \( \
  -name "secrets.yaml" -o -name "secrets.yml" -o -name "secrets.json" -o -name "secrets.env" \
  -o -name "*.secret.yaml" -o -name "*.secret.yml" -o -name "*.secret.json" -o -name "*.secret.env" \
\) 2>/dev/null || true)

# 3. inspect staged files in git
if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
  while IFS= read -r staged_file; do
    if [[ -n "$staged_file" && -f "$staged_file" ]]; then
      if [[ "$staged_file" =~ (secrets|secret)\.(yaml|yml|json|env)$ ]]; then
        SECRET_FILES["./$staged_file"]=1
      fi
    fi
  done < <(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)
fi

is_encrypted() {
  local target="$1"
  local ext="${target##*.}"

  if [[ "$ext" == "json" ]]; then
    grep -q '"sops":' "$target" 2>/dev/null && grep -q 'ENC\[' "$target" 2>/dev/null
  elif [[ "$ext" == "env" ]]; then
    grep -q 'sops_' "$target" 2>/dev/null || grep -q 'ENC\[' "$target" 2>/dev/null
  else
    # yaml/yml default
    grep -q '^sops:' "$target" 2>/dev/null && grep -q 'ENC\[' "$target" 2>/dev/null
  fi
}

ENCRYPTED_COUNT=0
UNENCRYPTED_COUNT=0
ERROR_COUNT=0

for raw_file in "${!SECRET_FILES[@]}"; do
  file="${raw_file#./}"
  [[ ! -f "$file" ]] && continue

  if is_encrypted "$file"; then
    continue
  fi

  UNENCRYPTED_COUNT=$((UNENCRYPTED_COUNT + 1))
  echo "🔒 Detected unencrypted secret file: $file"

  if [[ "$HAS_SOPS" != "true" ]]; then
    echo "❌ Error: 'sops' command not found in PATH. Cannot encrypt $file." >&2
    ERROR_COUNT=$((ERROR_COUNT + 1))
    continue
  fi

  # encrypt in place using .sops.yaml rules
  if sops -e -i "$file"; then
    echo "✅ Successfully encrypted: $file"
    ENCRYPTED_COUNT=$((ENCRYPTED_COUNT + 1))

    # stage updated encrypted file in git if inside repo
    if git rev-parse --is-inside-work-tree &>/dev/null; then
      git add "$file"
      echo "📝 Staged encrypted $file in git index."
    fi
  else
    echo "❌ Failed to encrypt $file. Ensure matching creation rules in .sops.yaml." >&2
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi
done

# final guard: verify no unencrypted secret files are staged in git
if git rev-parse --is-inside-work-tree &>/dev/null; then
  while IFS= read -r staged_file; do
    [[ -z "$staged_file" || ! -f "$staged_file" ]] && continue
    if [[ "$staged_file" =~ (secrets|secret)\.(yaml|yml|json|env)$ ]] || [[ -v SECRET_FILES["./$staged_file"] ]]; then
      if ! is_encrypted "$staged_file"; then
        echo "🚨 Security Alert: Staged secret file '$staged_file' is NOT encrypted!" >&2
        ERROR_COUNT=$((ERROR_COUNT + 1))
      fi
    fi
  done < <(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)
fi

if [[ "$ERROR_COUNT" -gt 0 ]]; then
  echo "🚫 Pre-commit secret check failed: $ERROR_COUNT issue(s) detected. Commit aborted." >&2
  exit 1
fi

if [[ "$UNENCRYPTED_COUNT" -gt 0 ]]; then
  echo "🎉 Encrypted $ENCRYPTED_COUNT secret file(s)."
else
  echo "🔒 All secret files verified encrypted."
fi

exit 0
