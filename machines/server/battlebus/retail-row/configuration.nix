{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../../../common/core/default.nix
    ../../../../common/server/default.nix
    ./nginx.nix
  ];

  networking.hostName = "retail-row";

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
