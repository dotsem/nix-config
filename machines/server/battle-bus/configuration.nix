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
    ./nginx.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = lib.mkDefault "battle-bus";

  # SOPS secrets setup for Cloudflare Tunnel credentials
  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.cloudflare_tunnel_token = {
    restartUnits = [ "cloudflared-tunnel.service" ];
  };

  # Cloudflare Tunnel Systemd Service
  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel Ingress Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token $(cat ${config.sops.secrets.cloudflare_tunnel_token.path})'";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  environment.systemPackages = with pkgs; [
    cloudflared
    curl
    tmux
    vim
  ];

  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];
}
