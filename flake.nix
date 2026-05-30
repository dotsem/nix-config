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
          specialArgs = { inherit inputs; };
          modules = [
            ./common/core
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            ./common/disko-config.nix
            ./machines/server/battlebus/retail-row/configuration.nix
            { custom.server.description = "production server for GoStrategy"; }
          ];
        };

        lonely-lodge = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./common/core
            inputs.sops-nix.nixosModules.sops
            ./machines/server/battlebus/lonely-lodge/configuration.nix
            {
              custom.server.description = "logging stack with grafana, loki and promtail, logs for all nixos machines";
            }
          ];
        };
      };
    };
}
