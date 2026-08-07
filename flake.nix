{
  description = "Semdot NixOS Configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    dms.url = "github:AvengeMedia/DankMaterialShell";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      dms,
      disko,
      sops-nix,
      ...
    }@inputs:
    let
      hosts = import ./lib/hosts.nix;
    in
    {
      nixosConfigurations = {
        nasaPC = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./common/core
            ./common/desktop
            ./common/packages
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            ./machines/desktop/nasaPC/configuration.nix
          ];
        };

        toasterBTW = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./common/core
            ./common/desktop
            ./common/packages
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            ./machines/desktop/toasterBTW/configuration.nix
          ];
        };

        retail-row = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs hosts; };
          modules = [
            ./common/core
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            ./common/disko-config.nix
            ./machines/server/retail-row/configuration.nix
            { custom.server.description = "production server for GoStrategy"; }
          ];
        };

        lonely-lodge = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs hosts; };
          modules = [
            ./common/core
            inputs.sops-nix.nixosModules.sops
            ./machines/server/lonely-lodge/configuration.nix
            {
              custom.server.description = "logging stack with grafana, loki and promtail, logs for all nixos machines";
            }
          ];
        };

        adguard-home = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs hosts; };
          modules = [
            ./common/core
            inputs.sops-nix.nixosModules.sops
            ./machines/server/adguard-home/configuration.nix
            {
              custom.server.description = "AdGuard Home DNS server";
            }
          ];
        };

        lobby = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs hosts; };
          modules = [
            ./common/core
            inputs.sops-nix.nixosModules.sops
            ./machines/server/lobby/configuration.nix
            {
              custom.server.description = "Homepage gateway dashboard server";
            }
          ];
        };

        tailscale = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs hosts; };
          modules = [
            ./common/core
            inputs.sops-nix.nixosModules.sops
            ./machines/server/tailscale/configuration.nix
            {
              custom.server.description = "Tailscale Subnet Router & Exit Node LXC";
            }
          ];
        };
      };
    };
}
