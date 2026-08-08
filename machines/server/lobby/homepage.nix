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
      headerStyle = "clean";
      background = "/assets/background.webp";
      cardBlur = "xl";
      favicon = "/assets/favicon.png";
      quicklaunch = {
        searchDescriptions = true;
        hideInternetSearch = false;
        showSearchSuggestions = true;
        provider = "brave";
      };
    };

    widgets = [
      {
        datetime = {
          text_size = "2xl";
          locale = "en-GB";
          format = {
            timeStyle = "short";
            dateStyle = "medium";
            hour12 = false;
          };
        };
      }
      {
        search = {
          provider = "brave";
          target = "_blank";
          focus = true;
          showSearchSuggestions = true;
        };
      }
    ];

    services = [
      {
        "Infrastructure" = [
          {
            "Reboot-Van" = {
              icon = "proxmox.png";
              href = "https://${hosts.reboot-van.ip}:8006";
              widget = {
                type = "proxmox";
                url = "https://${hosts.reboot-van.ip}:8006";
                username = "lobby@pve!homepage";
                password = "{{HOMEPAGE_VAR_PROXMOX_KEY}}";
                node = "rebootvan";
              };
            };
          }
          {
            "Supply-Drop" = {
              icon = "proxmox.png";
              href = "https://${hosts.supply-drop.ip}:8006";
              widget = {
                type = "proxmox";
                url = "https://${hosts.supply-drop.ip}:8006";
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
              href = "http://${hosts.adguard-home.ip}:3000";
              widget = {
                type = "adguard";
                url = "http://${hosts.adguard-home.ip}:3000";
              };
            };
          }
          {
            "OpenWRT Router" = {
              icon = "openwrt.png";
              href = "http://${hosts.openwrt.ip}/cgi-bin/luci/";
            };
          }
          {
            "Netgear Switch" = {
              icon = "netgear.png";
              href = "http://${hosts.netgear-switch.ip}/login.cgi";
            };
          }
          {
            "Tailscale Admin" = {
              icon = "tailscale.png";
              href = "https://console.tailscale.com/admin/machines";
              widget = {
                type = "tailscale";
                deviceid = "nhYhJVxE2N11CNTRL";
                key = "{{HOMEPAGE_VAR_TAILSCALE_KEY}}";
              };
            };
          }
        ];
      }
      {
        "Monitoring" = [
          {
            "Grafana" = {
              icon = "grafana.png";
              href = "http://${hosts.lonely-lodge.ip}:3000";
            };
          }
          {
            "Dashboards" = [
              {
                "Server Snack" = {
                  icon = "/assets/grafana-alerts-dashboard.png";
                  href = "http://${hosts.lonely-lodge.ip}:3000/d/server-snack/server-snack?orgId=1&from=now-24h&to=now&timezone=browser&refresh=30s";
                };
              }
              {
                "GoStrategy Operations" = {
                  icon = "gomft.png";
                  href = "http://${hosts.lonely-lodge.ip}:3000/d/gostrategy-ops/gostrategy-e28094-operations?orgId=1&from=now-24h&to=now&timezone=browser&refresh=30s";
                };
              }
            ];
          }
          {
            "Prometheus" = {
              icon = "prometheus.png";
              href = "http://${hosts.lonely-lodge.ip}:9090/targets";
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

    customCSS = builtins.readFile ./custom.css;
  };
}
