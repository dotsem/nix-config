# Rebuild and switch a NixOS flake target host
_rebuild host ip:
    nix run nixpkgs#nixos-rebuild -- switch --flake .#{{host}} --target-host sem@{{ip}} --ask-sudo-password

# Install NixOS onto a clean target machine using nixos-anywhere
install host ip:
    nix run github:nix-community/nixos-anywhere -- --flake ".#{{host}}" "nixos@{{ip}}"

# Automate the deployment of master flake and .envrc files inside ~/prog
setup-dev:
    bash ./scripts/setup-devshells.sh

lonely-lodge: (_rebuild "lonely-lodge" "192.168.200.6")
retail-row:   (_rebuild "retail-row"   "192.168.200.4")
toast-test:   (_rebuild "toasterBTW"   "192.168.200.5")

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


