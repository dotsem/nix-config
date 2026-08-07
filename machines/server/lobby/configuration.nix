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
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "lobby";

  # Ensure self-signed TLS certificate is available for port 443 (HTTPS)
  systemd.services.nginx.preStart = ''
    if [ ! -f /var/lib/nginx/cert.pem ]; then
      mkdir -p /var/lib/nginx
      ${pkgs.openssl}/bin/openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout /var/lib/nginx/cert.key \
        -out /var/lib/nginx/cert.pem \
        -subj "/CN=lobby.home"
      chmod 600 /var/lib/nginx/cert.key
    fi
  '';

  # Native Homepage Dashboard Service
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8080;

    settings = {
      title = "Lobby Gateway";
      theme = "dark";
      color = "slate";
    };

    widgets = [
      {
        search = {
          provider = "brave";
          target = "_blank";
        };
      }
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
        };
      }
    ];

    services = [
      {
        "Infrastructure" = [
          {
            "Reboot-Van" = {
              icon = "proxmox.png";
              href = "http://192.168.10.10:8006";
              description = "Reboot-Van hypervisor node";
            };
          }
          {
            "Supply-Drop" = {
              icon = "proxmox.png";
              href = "http://192.168.10.11:8006";
              description = "Supply-Drop hypervisor node";
            };
          }
        ];
      }
      {
        "Networking" = [
          {
            "AdGuard Home" = {
              icon = "adguard-home.png";
              href = "http://192.168.10.100";
              description = "DNS & Ad Blocker";
              widget = {
                type = "adguard";
                url = "http://192.168.10.100";
              };
            };
          }
          {
            "Tailscale" = {
              icon = "tailscale.png";
              href = "https://console.tailscale.com/admin/machines";
              description = "Tailscale dashboard";
            };
          }
        ];
      }
      {
        "Monitoring" = [
          {
            "Grafana" = {
              icon = "grafana.png";
              href = "http://192.168.10.103:3000";
              description = "Metrics & Telemetry Dashboards";
            };
          }
          {
            "Prometheus" = {
              icon = "prometheus.png";
              href = "http://192.168.10.103:9090";
              description = "Metrics Scraper & Targets";
            };
          }
        ];
      }
      {
        "Applications" = [
          {
            "GoStrategy" = {
              icon = "nginx.png";
              href = "https://gostrategy.dotsem.be";
              description = "Production GoStrategy Server";
            };
          }
        ];
      }
    ];
  };

  # Reverse proxy Homepage on HTTP (80) & HTTPS (443)
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."lobby.home" = {
      default = true;
      serverAliases = [
        hosts.lobby.ip
        "_"
      ];
      addSSL = true;
      sslCertificate = "/var/lib/nginx/cert.pem";
      sslCertificateKey = "/var/lib/nginx/cert.key";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
      };
    };
  };

  # Open HTTP (80) and HTTPS (443) firewall ports
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
