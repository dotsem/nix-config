{
  config,
  pkgs,
  lib,
  hosts,
  ...
}:
{

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.homepage_env = {
    restartUnits = [ "homepage-dashboard.service" ];
  };

  # Native Homepage Dashboard Service
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8080;
    allowedHosts = "*";
    environmentFiles = [
      config.sops.secrets.homepage_env.path
    ];

    settings = {
      title = "Lobby - lab.dotsem.be";
      theme = "dark";
      color = "slate";
      background = {
        image = "https://upload.wikimedia.org/wikipedia/commons/5/53/John_Constable_-_Salisbury_Cathedral_from_the_Bishop%27s_Garden_-_Google_Art_Project.jpg";
        opacity = 50;
        blur = "xs";
      };
      cardBlur = "lg";
      favicon = "https://dotsem.be/_app/immutable/assets/favicon.BbzKcFA8.png";
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
              href = "https://192.168.10.10:8006";
              widget = {
                type = "proxmox";
                url = "https://192.168.10.10:8006";
                username = "lobby@pve!homepage";
                password = "{{HOMEPAGE_VAR_PROXMOX_KEY}}";
                node = "rebootvan";
              };
            };
          }
          {
            "Supply-Drop" = {
              icon = "proxmox.png";
              href = "https://192.168.10.11:8006";
              widget = {
                type = "proxmox";
                url = "https://192.168.10.11:8006";
                username = "lobby@pve!homepage";
                password = "{{HOMEPAGE_VAR_PROXMOX_KEY}}";
                node = "supplydrop";
              };
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
              widget = {
                type = "adguard";
                url = "http://192.168.10.100:3000";
              };
            };
          }
          {
            "Tailscale Dashboard" = {
              icon = "tailscale.png";
              href = "https://console.tailscale.com/admin/machines";
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
            };
          }
          {
            "Dashboards" = [
              {
                "Server Snack" = {
                  icon = "grafana-alerts-dashboard.png";
                  href = "http://192.168.10.103:3000/d/server-snack/server-snack?orgId=1&from=now-24h&to=now&timezone=browser&refresh=30s";
                };
              }
              {
                "GoStrategy Operations" = {
                  icon = "gomft.png";
                  href = "http://192.168.10.103:3000/d/gostrategy-ops/gostrategy-e28094-operations?orgId=1&from=now-24h&to=now&timezone=browser&refresh=30s";
                };
              }
            ];
          }
          {
            "Prometheus" = {
              icon = "prometheus.png";
              href = "http://192.168.10.103:9090";
            };
          }
        ];
      }
      {
        "Applications" = [
          {
            "GoStrategy" = {
              icon = "gomft.png";
              href = "https://gostrategy.dotsem.be";
              siteMonitor = "https://gostrategy.dotsem.be";
            };
          }
        ];
      }
    ];
  };
}
