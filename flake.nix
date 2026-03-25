{
  description = "Semdot NixOS Configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    dms.url = "github:AvengeMedia/DankMaterialShell";
    
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, dms, disko, ... }@inputs: {
    nixosConfigurations = {
      nasaPC = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./common/core
          ./common/desktop
          ./common/programming
          inputs.disko.nixosModules.disko
          ./machines/desktop/nasaPC/configuration.nix
        ];
      };

      toasterBTW = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./common/core
          ./common/desktop
          ./common/programming
          inputs.disko.nixosModules.disko
          ./machines/desktop/toasterBTW/configuration.nix
        ];
      };

      battlebus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./common/core
          ./machines/server/battlebus/nix-web/configuration.nix
        ];
      };
    };
  };
}