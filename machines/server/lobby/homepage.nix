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
      background = "https://upload.wikimedia.org/wikipedia/commons/5/53/John_Constable_-_Salisbury_Cathedral_from_the_Bishop%27s_Garden_-_Google_Art_Project.jpg";
      cardBlur = "xl";
      favicon = "https://dotsem.be/_app/immutable/assets/favicon.BbzKcFA8.png";
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
                  icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/png/grafana-alerts-dashboard.png";
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
              href = "http://${hosts.lonely-lodge.ip}:9090";
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

    customCSS = ''
      /* Search Container & Input (Targets Homepage's actual form selector) */
      form.information-widget-search {
        min-width: 360px !important;
      }

      form.information-widget-search input,
      #search-input {
        font-size: 1.1rem !important;
        padding: 0.7rem 1.2rem !important;
        border-radius: 0.85rem !important;
        backdrop-filter: blur(20px) !important;
        -webkit-backdrop-filter: blur(20px) !important;
        background-color: rgb(var(--color-theme-900) / 0.75) !important;
        border: 1px solid rgba(255, 255, 255, 0.15) !important;
        box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.35) !important;
        color: #fff !important;
        transition: all 0.2s ease-in-out !important;
      }

      form.information-widget-search input:focus,
      #search-input:focus {
        background-color: rgb(var(--color-theme-900) / 0.9) !important;
        border-color: rgba(255, 255, 255, 0.35) !important;
        box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.5) !important;
      }

      /* Use dynamic theme colors for frosted glass cards */
      .service-card {
        background-color: rgb(var(--color-theme-900) / 0.75) !important;
        border: 1px solid rgba(255, 255, 255, 0.12) !important;
        backdrop-filter: blur(16px) !important;
        -webkit-backdrop-filter: blur(16px) !important;
        box-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.35) !important;
      }

      .service-card:hover {
        background-color: rgb(var(--color-theme-800) / 0.85) !important;
        border-color: rgba(255, 255, 255, 0.25) !important;
      }

      /* Enhance contrast for category headers */
      .group-title, h2, h3 {
        text-shadow: 0 2px 4px rgba(0, 0, 0, 0.85) !important;
      }
    '';
  };
}
