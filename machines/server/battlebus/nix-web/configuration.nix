{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../../common/core/default.nix
    ../../../../common/server/boot.nix
  ];

  networking.hostName = "battlebus";

  # Enable QEMU Guest Agent for Proxmox
  services.qemuGuest.enable = true;

  # Disk configuration (overriding disko-config.nix default)
  disko.devices.disk.main.device = "/dev/sda";

  # Docker support
  virtualisation.docker.enable = true;
  users.users.sem.extraGroups = [ "docker" ];

  # Nginx Reverse Proxy
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."stratego.local" = {
      locations."/" = {
        proxyPass = "http://localhost:5173"; # Frontend
      };
      locations."/api" = {
        proxyPass = "http://localhost:8080"; # Backend
      };
      locations."/ws" = {
        proxyPass = "http://localhost:8080";
        proxyWebsockets = true;
      };
    };
  };

  # Cloudflare Tunnel
  # The user will need to provide the tunnel credentials/token
  # services.cloudflared = {
  #   enable = true;
  #   tunnels = {
  #     "stratego-tunnel" = {
  #       ingress = {
  #         "stratego.example.com" = "http://localhost:80"; # Points to Nginx
  #       };
  #       default = "http_status:404";
  #     };
  #   };
  # };

  # Minimal packages
  environment.systemPackages = with pkgs; [
    tmux
    vim
    rsync
    docker-compose
  ];

  # Basic firewall for server
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
}

