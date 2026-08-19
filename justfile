set dotenv-filename := "hosts.env"
set dotenv-load

# Rebuild and switch a NixOS flake target host
rebuild host ip action="switch":
    nix run nixpkgs#nixos-rebuild -- {{action}} --flake .#{{host}} --target-host root@{{ip}}

rebuild-all parallel="false":
    #!/usr/bin/env bash
    if [ "{{parallel}}" = "true" ]; then
        just adguard-home & just lobby & just lonely-lodge & just retail-row & just tailscale & just battle-bus & just greasy-grove & wait
    else
        just adguard-home
        just lobby
        just lonely-lodge
        just retail-row
        just tailscale
        just battle-bus
        just greasy-grove
    fi

# Install NixOS onto a clean target machine using nixos-anywhere
install host ip:
    nix run github:nix-community/nixos-anywhere -- --flake ".#{{host}}" "nixos@{{ip}}" --option ssh-extra-opts "-C"

# Automate the deployment of master flake and .envrc files inside ~/prog
setup-dev:
    bash ./scripts/setup-devshells.sh

# Configure Git pre-commit hooks via Lefthook
setup-hooks:
    chmod +x scripts/*.sh scripts/git/*.sh
    git config --unset core.hooksPath 2>/dev/null || true
    lefthook install
    @echo "Lefthook git hooks installed"

# Automatically encrypt all unencrypted SOPS secret files and re-stage if needed
encrypt-secrets:
    bash ./scripts/git/pre-commit-encrypt-secrets.sh

adguard-home:  (rebuild "adguard-home"  env_var("ADGUARD_HOME_IP"))
lobby:         (rebuild "lobby"         env_var("LOBBY_IP"))
tailscale:     (rebuild "tailscale"     env_var("TAILSCALE_IP"))
lonely-lodge: (rebuild "lonely-lodge" env_var("LONELY_LODGE_IP"))
retail-row:   (rebuild "retail-row"   env_var("RETAIL_ROW_IP"))
battle-bus:   (rebuild "battle-bus"   env_var("BATTLE_BUS_IP"))
greasy-grove: (rebuild "greasy-grove" env_var("GREASY_GROVE_IP"))

# Prepare target configuration for initial fast bootstrap (essential apps only)
bootstrap-prep:
    ./scripts/toggle-profile.sh disable

# Perform post-install over SSH (enables full profile and rebuilds target host)
post-install host ip:
    ./scripts/toggle-profile.sh enable
    nix run nixpkgs#nixos-rebuild -- switch --flake .#{{host}} --target-host sem@{{ip}} --ask-sudo-password

# Perform post-install locally (enables full profile and rebuilds local host)
post-install-local host:
    ./scripts/toggle-profile.sh enable
    sudo nixos-rebuild switch --flake .#{{host}}


