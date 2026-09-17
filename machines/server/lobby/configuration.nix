{
  config,
  pkgs,
  lib,
  hosts,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ../../../common/core/default.nix
    ../../../common/server/default.nix
    ./homepage.nix
    ./gatus.nix
    ./ntfy.nix
    ./healthchecks.nix
    ./wol.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "lobby";

  sops.defaultSopsFile = ./secrets.yaml;

  networking.firewall.allowedTCPPorts = [
    8080
    8090
  ];
}
