{ config, pkgs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../../common/core/default.nix
    ../../../../common/server/boot.nix
    ./nginx.nix
  ];

  networking.hostName = "retail-row";

  # Enable QEMU Guest Agent for Proxmox
  services.qemuGuest.enable = true;

  # Enable SSH
  services.openssh.enable = true;

  # Disk configuration (overriding disko-config.nix default)
  disko.devices.disk.main.device = "/dev/sda";

  # Docker support
  virtualisation.docker.enable = true;
  users.users.sem.extraGroups = [ "docker" ];

  # Securely run the Cloudflare Tunnel using your token from /etc/cloudflared/stratego.env
  systemd.services.stratego-tunnel = {
    description = "Cloudflare Tunnel for Stratego";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      EnvironmentFile = "/etc/cloudflared/stratego.env";
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token \${CLOUDFLARED_TOKEN}";
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
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
}

