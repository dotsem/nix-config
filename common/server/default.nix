{ config, pkgs, lib, ... }:
{
  imports = [
    ./boot.nix
    ./security.nix
    ./monitoring.nix
    ./motd.nix
    ./networking.nix
    ./sops.nix
  ];

  virtualisation.docker.package = lib.mkDefault (pkgs.docker_29 or pkgs.docker);
}
