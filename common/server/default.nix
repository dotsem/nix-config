{ config, ... }:
{
  imports = [
    ./boot.nix
    ./security.nix
    ./monitoring.nix
  ];
}
