# Rebuild and switch a NixOS flake target host
_rebuild host ip:
    nix run nixpkgs#nixos-rebuild -- switch --flake .#{{host}} --target-host sem@{{ip}} --ask-sudo-password

# Install NixOS onto a clean target machine using nixos-anywhere
install host ip:
    nix run github:nix-community/nixos-anywhere -- --flake ".#{{host}}" --extra-files ./common/disko-config.nix "nixos@{{ip}}"

# Automate the deployment of master flake and .envrc files inside ~/prog
setup-dev:
    bash ./scripts/setup-devshells.sh

lonely-lodge: (_rebuild "lonely-lodge" "192.168.200.6")
retail-row:   (_rebuild "retail-row"   "192.168.200.4")
toast-test:   (_rebuild "toasterBTW"   "192.168.200.5")

