# NixOS configuration

This repository contains the declarative, flake-based NixOS configurations for my infrastructure, targeting personal workstations, portable environments, and containerized/virtualized server nodes.

## Prerequisites & Tech Stack

The configuration depends on the following tools and services:
* **Nix / NixOS**: Target operating system using the unstable channel.
* **Nix Flakes**: Dependency resolution and configuration versioning.
* **Just**: Command execution and deployment runner.
* **SOPS (sops-nix)**: Encryption/decryption of secrets (tokens, passwords) using Age or PGP.
* **Disko**: Declarative partition styling and formatting.
* **GNU Stow**: Symlink-based dotfiles deployment.
* **Docker / Docker Compose**: Containerized services management on server targets.

## Repository Architecture

```
.
├── common/                # Shared module configurations
│   ├── core/              # Global system baselines (users, fish, git, boot, etc.)
│   ├── desktop/           # Desktop packages, window managers, fonts, virtualization
│   ├── server/            # Security policies, monitoring agents, MOTD
│   ├── packages/          # System-wide package classifications
│   └── disko-config.nix   # Shared disko partition schema
├── devshell/              # Centralized Development shell declarations
│   └── flake.nix          # Language-specific devShell outputs (Rust, Go, Web, Python, etc.)
├── docker/                # Multi-container orchestration directories
│   └── logging/           # Central Grafana/Loki/Promtail/Prometheus stack
└── machines/              # Machine-specific settings and configurations
    ├── desktop/           # Desktop hosts
    └── server/            # Server hosts

```

## Machine Outlines

The flake defines four primary NixOS configurations:

| Host Name | Type | Key Configurations & Features | File Path |
| :--- | :--- | :--- | :--- |
| **nasaPC** | Desktop | Proprietary NVIDIA drivers, Steam, and GameMode optimization. | `machines/desktop/nasaPC` |
| **toasterBTW** | Laptop | Power management tuning (TLP), Intel & NVIDIA hybrid graphics with PRIME offloading, libinput, and thermald. | `machines/desktop/toasterBTW` |
| **retail-row** | Server | Production server for GoStrategy. Nginx reverse proxy integration. | `machines/server/battlebus/retail-row` |
| **lonely-lodge**| Server | Logging stack server running under Proxmox LXC. Orchestrates Grafana, Loki, Promtail, and Prometheus. | `machines/server/battlebus/lonely-lodge` |

## Getting Started & Setup

### Local Shell Development

Deploy language-specific devShell configurations (Go, Rust, Python, Web, Flutter, C/C++, C#, Java, PHP, Scripting) inside your local `~/prog` directories:

```bash
just setup-dev
```

This populates directories with `.envrc` files configured to use regional devShell targets and automatically authorizes them with `direnv`.

### Bootstrapping and Installing Targets

To install NixOS onto a clean target system over the network:

1. **Bootstrap Profile Toggle**: To optimize install speed, temporarily disable the installation of heavy graphical applications:
   ```bash
   just bootstrap-prep
   ```
2. **Install Target**: Execute the installation script over SSH:
   ```bash
   just install <host> <target-ip>
   ```
3. **Post-Install Activation**: Enable the full profile and complete the configuration build:
   - For remote machines:
     ```bash
     just post-install <host> <target-ip>
     ```
   - For local setups:
     ```bash
     just post-install-local <host>
     ```

### Rebuilding Configs

Rebuild a configuration target dynamically:

```bash
just rebuild <host> <target-ip>
# Example: rebuild retail-row
just retail-row
```
