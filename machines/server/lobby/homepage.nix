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
        greeting = {
          text_size = "2xl";
          text = "Welcome back, Sem";
        };
      }
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
    ];

    services = [
      {
        "Infrastructure" = [
          {
            "Cloudflare" = {
              icon = "cloudflare.png";
              href = "https://dash.cloudflare.com";
            };
          }
          {
            "GitHub" = {
              icon = "github.png";
              href = "https://github.com/dotsem?tab=repositories";
            };
          }
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
          {
            "Zero Point" = {
              icon = "proxmox.png";
              href = "https://${hosts.zero-point.ip}:8006";
              widget = {
                type = "proxmox";
                url = "https://${hosts.zero-point.ip}:8006";
                username = "lobby@pve!homepage";
                password = "{{HOMEPAGE_VAR_PROXMOX_KEY}}";
                node = "zeropoint";
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
            "OPNsense" = {
              icon = "opnsense.png";
              href = "http://${hosts.flush-factory.ip}/";
              # TODO
              # widget = {
              #   type = "opnsense";
              #   url = "http://${hosts.flush-factory.ip}";
              #   username = "admin";
              #   password = "[PASSWORD]";
              # }; 
            };
          }
          {
            "Netgear Switch" = {
              icon = "netgear.png";
              href = "http://${hosts.netgear-switch.ip}/login.cgi";
            };
          }
          {
            "Tailscale" = [
              {
                "Flush Factory" = {
                  icon = "tailscale.png";
                  href = "https://console.tailscale.com/admin/machines";
                  widget = {
                    type = "tailscale";
                    deviceid = "nQr8NoUgZe11CNTRL";
                    key = "{{HOMEPAGE_VAR_TAILSCALE_KEY}}";
                  };
                };
              }
              {
                "Tailscale LXC" = {
                  icon = "tailscale.png";
                  href = "https://console.tailscale.com/admin/machines";
                  widget = {
                    type = "tailscale";
                    deviceid = "njYm5oWd4w11CNTRL";
                    key = "{{HOMEPAGE_VAR_TAILSCALE_KEY}}";
                  };
                };
              }
              {
                "ToasterBTW" = {
                  icon = "tailscale.png";
                  href = "https://console.tailscale.com/admin/machines";
                  widget = {
                    type = "tailscale";
                    deviceid = "nPsj49Gwp921CNTRL";
                    key = "{{HOMEPAGE_VAR_TAILSCALE_KEY}}";
                  };
                };
              }
              {
                "Geen Telefoon" = {
                  icon = "tailscale.png";
                  href = "https://console.tailscale.com/admin/machines";
                  widget = {
                    type = "tailscale";
                    deviceid = "nMA39HdmhW11CNTRL";
                    key = "{{HOMEPAGE_VAR_TAILSCALE_KEY}}";
                  };
                };
              }
            ];
          }
        ];
      }
      {
        "Monitoring" = [
          {
            "Status Pages" = [
              {
                "Public Projects" = {
                  icon = "gatus.png";
                  href = "https://uptime.dotsem.be";
                  siteMonitor = "https://uptime.dotsem.be";
                };
              }
              {
                "Homelab Internal" = {
                  icon = "gatus.png";
                  href = "https://uptime-internal.dotsem.be";
                  siteMonitor = "http://${hosts.lobby.ip}:4001";
                };
              }
              {
                "External Stalker" = {
                  icon = "gatus.png";
                  href = "https://uptime-stalker.dotsem.be";
                  siteMonitor = "http://${hosts.lobby.ip}:4002";
                };
              }
            ];
          }
          {
            "Grafana" = {
              icon = "grafana.png";
              href = "https://grafana.dotsem.be";
              siteMonitor = "https://grafana.dotsem.be";
            };
          }
          {
            "Dashboards" = [
              {
                "Server Snack" = {
                  icon = "/assets/grafana-alerts-dashboard.png";
                  href = "https://grafana.dotsem.be/d/server-snack-overview";
                };
              }
              {
                "GoStrategy Operations" = {
                  icon = "gomft.png";
                  href = "https://grafana.dotsem.be/d/gostrategy-ops";
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
            "Production" = [
              {
                "World Wide Bulb" = {
                  icon = "/assets/bulb.png";
                  href = "https://wwb.dotsem.be";
                  siteMonitor = "https://wwb.dotsem.be";
                };
              }
              {
                "GoStrategy" = {
                  icon = "gomft.png";
                  href = "https://gostrategy.dotsem.be";
                  siteMonitor = "https://gostrategy.dotsem.be";
                };
              }
              {
                "Portfolio" = {
                  icon = "/assets/favicon.png";
                  href = "https://dotsem.be";
                  siteMonitor = "https://dotsem.be";
                };
              }
            ];
          }
          {
            "Staging" = [
              {
                "World Wide Bulb" = {
                  icon = "/assets/bulb.png";
                  href = "https://staging-wwb.dotsem.be";
                  siteMonitor = "https://staging-wwb.dotsem.be";
                };
              }
            ];
          }
        ];
      }
    ];

    customCSS = builtins.readFile ./custom.css;
  };
}
