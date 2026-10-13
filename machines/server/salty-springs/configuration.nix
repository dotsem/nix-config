{
  config,
  pkgs,
  lib,
  hosts,
  ...
}:
let
  keys = import ../../../lib/keys.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../../common/core/default.nix
    ../../../common/server/default.nix
  ];

  networking.hostName = "salty-springs";

  sops.defaultSopsFile = ./secrets.yaml;

  # Static IP — values sourced from lib/hosts.nix.
  networking.useDHCP = false;
  networking.interfaces.ens18.ipv4.addresses = [
    {
      address = hosts.salty-springs.ip;
      prefixLength = hosts.salty-springs.prefixLength;
    }
  ];
  networking.defaultGateway = {
    address = hosts.salty-springs.gateway;
    interface = "ens18";
  };

  # Enable QEMU Guest Agent for Proxmox
  services.qemuGuest.enable = true;

  # Enable SSH
  services.openssh.enable = true;
  users.users.sem.openssh.authorizedKeys.keys = [ keys.retailRowDeploy_wwb ];

  # Disk configuration (overriding disko-config.nix default)
  disko.devices.disk.main.device = "/dev/sda";

  # Docker support
  virtualisation.docker.enable = true;
  users.users.sem.extraGroups = [ "docker" ];

  # Minimal packages
  environment.systemPackages = with pkgs; [
    tmux
    vim
    rsync
    docker-compose
  ];

  networking.firewall.allowedTCPPorts = [
    22
    # GoStrategy staging
    1010
    1011
    # World Wide Bulb staging
    5010
  ];
}
