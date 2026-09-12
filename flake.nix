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

      mkServer = extraModules: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs hosts; };
        modules = [
          ./common/core
          inputs.sops-nix.nixosModules.sops
        ] ++ extraModules;
      };
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

        retail-row = mkServer [
          inputs.disko.nixosModules.disko
          ./common/disko-config.nix
          ./machines/server/retail-row/configuration.nix
          { custom.server.description = "production server for GoStrategy"; }
        ];

        lonely-lodge = mkServer [
          ./machines/server/lonely-lodge/configuration.nix
          {
            custom.server.description = "logging stack with grafana, loki and promtail, logs for all nixos machines";
          }
        ];

        adguard-home = mkServer [
          ./machines/server/adguard-home/configuration.nix
          { custom.server.description = "AdGuard Home DNS server"; }
        ];

        adguard-home-zp = mkServer [
          ./machines/server/adguard-home/configuration.nix
          {
            networking.hostName = "adguard-home-zp";
            custom.server.description = "Secondary AdGuard Home DNS server on zeropoint";
          }
        ];

        lobby = mkServer [
          ./machines/server/lobby/configuration.nix
          { custom.server.description = "Homepage gateway dashboard server"; }
        ];

        tailscale = mkServer [
          ./machines/server/tailscale/configuration.nix
          { custom.server.description = "Tailscale Subnet Router & Exit Node LXC"; }
        ];

        battle-bus = mkServer [
          ./machines/server/battle-bus/configuration.nix
          { custom.server.description = "Edge Ingress Gateway with Nginx & Cloudflare Tunnel"; }
        ];

        battle-bus-sd = mkServer [
          ./machines/server/battle-bus/configuration.nix
          {
            networking.hostName = "battle-bus-sd";
            custom.server.description = "Secondary Edge Ingress Gateway on supplydrop";
          }
        ];

        greasy-grove = mkServer [
          ./machines/server/greasy-grove/configuration.nix
          { custom.server.description = "Kitchen, inventory & pantry logistics server (Homebox & KitchenOwl)"; }
        ];

        lxc-template = mkServer [
          ./machines/server/lxc-template/configuration.nix
          { custom.server.description = "Base Proxmox NixOS LXC Template"; }
        ];
      };

      packages.x86_64-linux = {
        lxc-template = self.nixosConfigurations.lxc-template.config.system.build.tarball;
      };
    };
}
