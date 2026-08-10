# AI Assistant Guidelines (NixOS Homelab & Systems)

These guidelines govern all AI interactions within this repository. Adhere strictly to these principles and repository conventions.

---

## 1. Core Operating Principles

### 1.1. Absolute Ban on Git Operations
- **NEVER execute or interact with Git.** Do not run `git commit`, `git add`, `git push`, `git checkout`, `git stash`, or any other Git command.
- All version control, staging, hook verification, and commit operations are strictly reserved for the human user.
- Focus purely on analyzing, creating, and modifying configuration files.
- Use `git status`, `git log`, `git diff`, and `git grep` only to backtrack issues.

### 1.2. Always Plan Before Acting
- Analyze existing host topology, module hierarchy, and dependencies before modifying code.
- Formulate a clear, structured plan outlining affected files, new options, and potential side-effects before implementing changes.
- Ensure architectural alignment across shared modules (`common/`) and target machine configurations (`machines/`).

### 1.3. Leverage Nix MCP for Verification
- **Always verify packages and options using the Nix MCP server** (`nix` and `nix_versions` tools).
- Never guess or hallucinate NixOS options, package names, or attribute paths. Query the MCP to confirm options exist in the target NixOS channel.
- Check commit-accurate package history or flake inputs via MCP whenever dependency or version ambiguities arise.

### 1.4. Declarative First (Code > GUI)
- Everything must be declared in code. Always prefer pure NixOS options, Disko partitioning, container definitions, and systemd units over manual or GUI-based configuration.
- If a service provides a web GUI, configure all initial state, credentials, networking, and settings declaratively via NixOS modules or config templates rather than manual post-install wizard clicks.
- Maintain reproducibility: any machine must be fully reconstructible from this repository alone.

### 1.5. Security-First Mindset & Secrets
- **Zero Plaintext Secrets**: Never embed API keys, passwords, private keys, or tokens in `.nix` files or unencrypted files.
- **SOPS & Age Encryption**: All secrets must use `sops-nix` and Age encryption following the rules declared in [`.sops.yaml`](file:///home/sem/nix-config/.sops.yaml).
- **Network & Service Hardening**:
  - Always audit firewall ports (`networking.firewall`). Expose only required ports.
  - Apply systemd service hardening flags (`ProtectSystem`, `ProtectHome`, `PrivateTmp`, `DynamicUser`, `NoNewPrivileges`) where applicable.
  - Route external traffic strictly through the edge ingress gateway (`battle-bus` / Cloudflare Tunnel / Nginx) or the Tailscale mesh.

### 1.6. Code Comment Standards
- **Omit obvious comments**: Never write comments that merely restate what the syntax does (e.g., avoid `# enable nginx` above `services.nginx.enable = true;`).
- **Explain the "Why", "WTF", and Gotchas**: Use comments exclusively to document non-obvious workarounds, upstream bugs, hardware quirks, or crucial architectural decisions.
- **Comment Style**: Keep short inline comments lowercase. Use capitalized sentences only for multi-line contextual explanations.

### 1.7. DRY Principles & Modularity (< 300 Lines Limit)
- **DRY (Don't Repeat Yourself)**: Extract shared logic into reusable modules under `common/` instead of duplicating across host configurations.
- **File Limit**: Strict ceiling of **300 lines per file**. If a configuration grows too large, decouple it into logical sub-modules (e.g., `hardware.nix`, `services.nix`, `network.nix`).

---

## 2. Repository Architecture & Layout

```
.
├── common/                # Shared reusable NixOS modules
│   ├── core/              # Global baseline (users, SSH, shell, boot)
│   ├── desktop/           # Desktop environments, audio, display managers
│   ├── server/            # Hardened server baseline, telemetry agents
│   ├── packages/          # Shared system package profiles
│   └── disko-config.nix   # Declarative disk layouts
├── machines/              # Host-specific definitions
│   ├── desktop/           # Workstations & laptops (nasaPC, toasterBTW)
│   └── server/            # LXCs & VMs (adguard-home, lobby, retail-row, etc.)
├── lib/
│   └── hosts.nix          # Single source of truth for static IPs & domains
├── devshell/              # Flake devshell environments for languages & tools
├── docker/                # Multi-container orchestration (e.g., telemetry stack)
├── scripts/               # Operational utility scripts
├── flake.nix              # Root entrypoint declaring all nixosConfigurations
├── hosts.env              # Environment variable bridge for Just runner recipes
├── justfile               # Operational recipe runner (rebuilds, bootstrap)
└── .sops.yaml             # SOPS encryption keys and path rules
```

---

## 3. Host & Network Topology Rules

- **IP Management**: [`lib/hosts.nix`](file:///home/sem/nix-config/lib/hosts.nix) is the single source of truth for all static machine IPs and subnets.
- When adding or modifying a server's network configuration:
  1. Declare the static IP and domain in [`lib/hosts.nix`](file:///home/sem/nix-config/lib/hosts.nix).
  2. Map the environment variable in [`hosts.env`](file:///home/sem/nix-config/hosts.env) for `just` runner recipes.
  3. Add the rebuild recipe to [`justfile`](file:///home/sem/nix-config/justfile).
  4. Declare the host configuration in [`flake.nix`](file:///home/sem/nix-config/flake.nix).

---

## 4. Operational & Deployment Context

- Deployments are executed via `just` (e.g., `just <hostname>` or `just rebuild <host> <ip>`).
- Initial provisioning uses `nixos-anywhere` via `just install <host> <ip>`.
- Let deployment to the human, they'll run the `just` commands.
