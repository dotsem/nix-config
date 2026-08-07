{
  config,
  pkgs,
  lib,
  hosts,
  ...
}:
{
  # Native Homepage Dashboard Service
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8080;
    allowedHosts = "*";

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
              href = "http://192.168.10.100:3000";
              description = "DNS & Ad Blocker";
              widget = {
                type = "adguard";
                url = "http://192.168.10.100:3000";
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
}
