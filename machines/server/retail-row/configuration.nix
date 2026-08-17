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

  networking.hostName = "retail-row";

  # Static IP — values sourced from lib/hosts.nix.
  networking.useDHCP = false;
  networking.interfaces.ens18.ipv4.addresses = [
    {
      address = hosts.retail-row.ip;
      prefixLength = hosts.retail-row.prefixLength;
    }
  ];
  networking.defaultGateway = {
    address = hosts.retail-row.gateway;
    interface = "ens18";
  };
  networking.nameservers = [
    hosts.adguard-home.ip
    "1.1.1.1"
  ];

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

  # Expose GoStrategy (:1000, :1001) and World Wide Bulb (:5000) to battle-bus ingress
  networking.firewall.allowedTCPPorts = [
    22
    1000
    1001
    5000
  ];
}
