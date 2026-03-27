{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../../common/core/default.nix
    ../../../../common/server/boot.nix
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

  # Nginx Reverse Proxy
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."stratego.dotsem.be" = {
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

   services.cloudflared = {
    enable = true;
    tunnels = {
      "stratego-tunnel" = {
        token = "dummy"; 
        ingress = {
          "stratego.dotsem.be" = "http://localhost:80";
        };
        default = "http_status:404";
      };
    };
  };

  systemd.services."cloudflared-tunnel-stratego-tunnel" = {
    serviceConfig = {
      EnvironmentFile = "/etc/cloudflared/stratego.env";
      ExecStart = lib.mkForce "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token \${CLOUDFLARED_TOKEN}";
    };
  };


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

