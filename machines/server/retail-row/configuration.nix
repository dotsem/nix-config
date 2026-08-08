{
  config,
  pkgs,
  lib,
  hosts,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../../common/core/default.nix
    ../../../common/server/default.nix
    ./nginx.nix
  ];

  networking.hostName = "retail-row";

  # Static IP — values sourced from lib/hosts.nix.
  # Verify interface name with `ip link` on the machine; Proxmox VMs commonly use ens18.
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
  networking.nameservers = [ hosts.adguard-home.ip "1.1.1.1" ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.cloudflare_tunnel_token = {};

  # Enable QEMU Guest Agent for Proxmox
  services.qemuGuest.enable = true;

  # Enable SSH
  services.openssh.enable = true;

  # Disk configuration (overriding disko-config.nix default)
  disko.devices.disk.main.device = "/dev/sda";

  # Docker support
  virtualisation.docker.enable = true;
  users.users.sem.extraGroups = [ "docker" ];

  # Securely run the Cloudflare Tunnel using your token from sops-nix
  systemd.services.stratego-tunnel = {
    description = "Cloudflare Tunnel for Stratego";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token $(cat ${config.sops.secrets.cloudflare_tunnel_token.path})'";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # Minimal packages
  environment.systemPackages = with pkgs; [
    tmux
    vim
    rsync
    docker-compose
    cloudflared
  ];

  # Basic firewall for server
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];
}
