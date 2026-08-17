# NixOS System Configuration

This is my personal config for my workstations (work in progress) and my homelab running Proxmox with NixOS VMs & LXCs.

## Architecture & Tech Stack

This repository uses NixOS 26.05 and the following declarative tools:

* **Nix Flakes**: Hermetic dependency locking and modular output definitions.
* **SOPS (`sops-nix`)**: Age-based secret encryption for system credentials and environment configuration.
* **Disko**: Declarative disk partitioning and filesystem formatting.
* **Just**: Command execution runner for system rebuilds, deployment automation, and devshell provisioning.
* **Direnv**: Automatic directory-based development shell loading via Flake targets.
* **Docker & Docker Compose**: Container orchestration for application workloads and telemetry infrastructure.

## Repository Layout

```
.
├── common/                # Shared NixOS modules
│   ├── core/              # Global baseline (user accounts, shell settings, SSH keys, boot settings)
│   ├── desktop/           # Graphical environments, audio, display managers, virtualization
│   ├── server/            # Hardened baseline, security profiles, monitoring agents
│   ├── packages/          # System-wide package definitions and profile toggle states
│   └── disko-config.nix   # Declarative disk partition layouts
├── devshell/              # Language-specific devshell configurations
│   └── flake.nix          # Flake outputs for Rust, Go, Python, Web, Flutter, C/C++, C#, Java, PHP
├── docker/                # Multi-container orchestration configurations
│   └── logging/           # Central Grafana, Loki, Promtail, and Prometheus telemetry stack
├── lib/                   # Infrastructure configuration helpers
│   └── hosts.nix          # Static IP definitions and network topology mappings
├── machines/              # Host-specific configurations
│   ├── desktop/           # Workstation and laptop host configurations (nasaPC, toasterBTW)
│   └── server/            # LXC and VM server configurations (adguard-home, lonely-lodge, retail-row, tailscale)
├── scripts/               # Operational automation scripts (devshell setup, profile toggle, git hooks)
├── flake.nix              # Main flake entrypoint defining nixosConfigurations
├── hosts.env              # Environment variable bridge for Just runner recipes
└── .sops.yaml             # SOPS recipient key mapping and encryption scope rules
```

## Host Matrix

| Host Name | Target Type | Static IP | Purpose & Specifications | Configuration Path |
| :--- | :--- | :--- | :--- | :--- |
| **nasaPC** | Desktop | Dynamic (DHCP) | High-performance workstation. NVIDIA proprietary drivers, Steam, GameMode optimizations. | `machines/desktop/nasaPC` |
| **toasterBTW** | Workstation | Dynamic (DHCP) | Mobile laptop setup. TLP power management, Intel/NVIDIA hybrid graphics (PRIME offloading), thermald. | `machines/desktop/toasterBTW` |
| **adguard-home** | Server (LXC) | `192.168.10.100` | Network-wide DNS resolution and ad-blocking server. | `machines/server/adguard-home` |
| **lobby** | Server (LXC) | `192.168.10.101` | Central homelab gateway dashboard (Homepage) on HTTP (80). | `machines/server/lobby` |
| **retail-row** | Server (VM) | `192.168.10.102` | Production application server hosting GoStrategy and World Wide Bulb with Nginx reverse proxy. | `machines/server/retail-row` |
| **lonely-lodge** | Server (LXC) | `192.168.10.103` | Telemetry & log aggregation node running Docker-managed Grafana, Loki, Promtail, and Prometheus. | `machines/server/lonely-lodge` |
| **tailscale** | Server (LXC) | `192.168.10.110` | Secure remote access subnet router and exit node. | `machines/server/tailscale` |

## Getting Started & Workflows

### Operational Environment Prerequisites

Ensure the following runtimes and tools are installed on your control node:

* Nix with Flakes enabled (`nix-command` and `flakes` experimental features)
* `just` command runner
* `sops` and `age` CLI tools for secret management

### Initial Repository Setup & DevShell Provisioning

After cloning the repository, initialize the local environment and activate Git pre-commit hooks:

```bash
# Set up Git pre-commit hooks (links core.hooksPath to .githooks)
just setup-hooks

# Or provision localized language devshells inside ~/prog and configure hooks simultaneously
just setup-dev
```

> [!IMPORTANT]
> Git does not run repository-tracked hooks automatically after cloning. You must run `just setup-hooks` once per cloned instance to activate automatic secret encryption and host verification guards.

### Secret Management & Pre-commit Hooks

SOPS secret files (`machines/**/secrets.yaml`) are automatically protected by Git pre-commit hooks:

* **Automatic Pre-commit Encryption**: When committing changes, `.githooks/pre-commit` detects any unencrypted secret files matching `.sops.yaml` creation rules or `*secrets*.{yaml,yml,json,env}`, encrypts them in place using `sops -e -i`, and re-stages them.
* **Commit Security Guard**: Commits are automatically blocked if any plaintext secret cannot be encrypted or if required recipient keys are missing.
* **Manual Commands**:
  ```bash
  # Encrypt all unencrypted secret files across the repository
  just encrypt-secrets

  # Verify all secret files are safely encrypted
  just check-secrets

  # Manually configure/re-link Git hooks
  just setup-hooks
  ```

### Target Rebuilds & Deployments

Host IPs are declared in `lib/hosts.nix` and bridged via `hosts.env`. Execute remote rebuilds through `just`:

```bash
# Rebuild specific server targets
just adguard-home
just lobby
just lonely-lodge
just retail-row
just tailscale

# Rebuild all server targets sequentially or in parallel
just rebuild-all
just rebuild-all --parallel

# Rebuild a custom target host
just rebuild <host> <target-ip>
```

### Initial Node Installation (Bootstrap)

To deploy NixOS onto a target machine over SSH using `nixos-anywhere`:

1. **Disable heavy desktop profiles for fast bootstrapping**:
   ```bash
   just bootstrap-prep
   ```

2. **Execute remote installation**:
   ```bash
   just install <host> <target-ip>
   ```

3. **Activate full package profile & finalize deployment**:
   * Remote targets:
     ```bash
     just post-install <host> <target-ip>
     ```
   * Local host:
     ```bash
     just post-install-local <host>
     ```

## Why NixOS?

No need to document anything (or almost) in a Google Doc. The whole system is declared and reproducible. 
I can spin up the same system on a new machine with the same configuration and it will be identical to the old one.
It also gives an easy centralized way of configuring servers, without ever forgetting what you exactly configured.
It is also incredibly powerful in the age of AI to find bugs, improve my system and find new ways to use it.