# env-catcher

`env-catcher` is a Go CLI utility designed to recursively discover, deduplicate, and securely back up untracked environment configuration files (`.env`, `.env.*`, `*.env`) across workspace directory trees.

The tool protects sensitive application secrets prior to environment transitions, system migrations, or disk wipes by centralizing scattered `.env` files into a protected directory or a compressed `.tar.gz` archive with strict POSIX permissions.

## Architecture & Features

* **Recursive Traversal & Pruning**: Walks source directories while automatically skipping heavy and non-relevant directories (`.git`, `node_modules`, `.direnv`, `target`, `dist`, `.cache`, `build`, `.venv`, `.cargo`, etc.) to minimize I/O overhead.
* **Git Tracking Guard**: Integrates with `git ls-files` (`-skip-git-tracked=true` by default) to filter out `.env` files already committed to version control, targeting only local and sensitive secrets.
* **Smart Filtering**: Automatically excludes non-secret artifacts, templates, and backups (`*.template`, `*.example`, `*.sample`, `*.dist`, `*.bak`, `*.swp`, `*.tmp`, `*.test.env`).
* **Path-Flattening & Hierarchy Preservation**: By default, flattens nested paths into snake_case prefixed file names (e.g., `services/auth/.env` becomes `services_auth.env`). Optionally preserves exact relative directory structures using `-preserve-tree` for seamless 1:1 project restoration.
* **Deduplication via SHA-256**: Hashes source files to detect identical content across directories (`skipped (identical)`). In the event of a filename collision with differing content, it appends an incrementing numeric suffix (e.g., `services_auth_1.env`).
* **Enforced Permissions**: Writes destination directories with `0700` permissions and outputs all backup files and tar archive entries with `0600` file modes.
* **Dual Output Modes**: Supports writing directly to a destination directory or packing directly into a standalone gzip-compressed tarball (`.tar.gz`).
* **Dry-Run Inspection**: Allows previewing scan results and copy actions without performing filesystem writes.

## Prerequisites & Tech Stack

* **Runtime & Compiler**: Go 1.22 or higher
* **External Dependencies**: `git` executable present in `$PATH` (used by the Git tracking filter)
* **Platform**: Linux / POSIX-compliant environments

## Getting Started & Usage

### Building the Binary

Compile the standalone binary using the Go toolchain:

```bash
cd scripts/env-catcher
go build -o env-catcher ./cmd/env-catcher
```

### CLI Synopsis

```text
Usage: env-catcher [options] <scan_directory> [destination_directory]

Options:
  -scan string
        Directory to scan for .env files
  -dest string
        Destination directory for backups
  -archive string
        Path to output .tar.gz bundle (overrides -dest)
  -dry-run
        Preview actions without writing files
  -preserve-tree
        Preserve relative directory structure instead of flattening filenames
  -skip-git-tracked
        Skip .env files that are already tracked by git (default true)
  -patterns string
        Comma-separated glob patterns (default: .env,.env.*,*.env)
  -exclude string
        Additional comma-separated patterns to exclude
  -prune string
        Additional comma-separated directory names to prune
```

### Common Execution Workflows

#### 1. Dry-Run Inspection

Preview all discoverable uncommitted environment files across a development directory without writing files to disk:

```bash
./env-catcher -dry-run -scan ~/prog -dest ~/backup/envs
```

#### 2. Directory Backup

Scan a workspace and copy all discovered environment files into a target directory using flattened filenames:

```bash
./env-catcher -scan ~/prog -dest ~/backup/envs
```

Positional arguments can also be used as shorthand:

```bash
./env-catcher ~/prog ~/backup/envs
```

#### 3. Compressed Tarball Archive

Stream matched environment files directly into an encrypted or compressed `.tar.gz` bundle:

```bash
./env-catcher -scan ~/prog -archive ~/backup/envs_backup.tar.gz
```

#### 4. Preserve Directory Hierarchy

Retain relative directory paths in the backup directory or compressed archive for 1:1 automated restores:

```bash
# Preserve folder hierarchy in target directory
./env-catcher -preserve-tree -scan ~/prog -dest ~/backup/envs

# Preserve folder hierarchy inside tarball archive
./env-catcher -preserve-tree -scan ~/prog -archive ~/backup/envs_tree.tar.gz
```

#### 5. Custom Globs and Directory Pruning

Include additional custom patterns while skipping extra vendor directories:

```bash
./env-catcher \
  -scan ~/prog \
  -dest ~/backup/envs \
  -patterns ".env,.env.*,*.env,secrets.conf" \
  -prune "vendor,third_party" \
  -exclude "*.mock.env"
```

#### 6. Include Git-Tracked Files

Disable git-tracking filters to capture all files matching environment patterns regardless of repository tracking state:

```bash
./env-catcher -skip-git-tracked=false -scan ~/prog -dest ~/backup/envs
```
