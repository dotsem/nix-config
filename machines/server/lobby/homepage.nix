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
      /* Search bar styling */
      form.information-widget-search {
        min-width: 360px !important;
      }

      form.information-widget-search input,
      #search-input {
        font-size: 1.05rem !important;
        padding: 0.65rem 1.2rem !important;
        border-radius: 0.75rem !important;
        backdrop-filter: blur(16px) !important;
        -webkit-backdrop-filter: blur(16px) !important;
        background-color: rgba(15, 23, 42, 0.85) !important;
        border: 1px solid rgba(255, 255, 255, 0.15) !important;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3) !important;
        color: #ffffff !important;
        transition: all 0.2s ease-in-out !important;
      }

      form.information-widget-search input:focus,
      #search-input:focus {
        background-color: rgba(15, 23, 42, 0.95) !important;
        border-color: rgba(255, 255, 255, 0.35) !important;
      }

      /* Dark frosted glass cards for high contrast against wallpaper */
      .service-card {
        background-color: rgba(15, 23, 42, 0.85) !important;
        border: 1px solid rgba(255, 255, 255, 0.1) !important;
        backdrop-filter: blur(16px) !important;
        -webkit-backdrop-filter: blur(16px) !important;
        box-shadow: 0 4px 14px rgba(0, 0, 0, 0.25) !important;
      }

      .service-card:hover {
        background-color: rgba(15, 23, 42, 0.95) !important;
        border-color: rgba(255, 255, 255, 0.22) !important;
      }

      /* Clean readable text inside cards */
      .service-card span,
      .service-card p {
        color: #f1f5f9 !important;
      }

      /* Clean category headers without blurry smudges */
      .group-title, h2, h3 {
        color: #ffffff !important;
        text-shadow: 0 1px 3px rgba(0, 0, 0, 0.7) !important;
      }
    '';
  };
}
