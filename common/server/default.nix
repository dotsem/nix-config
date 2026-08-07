{ config, ... }:
{
  imports = [
    ./boot.nix
    ./security.nix
    ./monitoring.nix
    ./motd.nix
    ./networking.nix
  ];
}
