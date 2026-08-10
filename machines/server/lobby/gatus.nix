{
  config,
  pkgs,
  lib,
  hosts,
  ...
}:
{
  services.gatus = {
    enable = true;
    openFirewall = true;
    settings = {
      web.port = 4000;
      storage = {
        type = "sqlite";
        path = "/var/lib/gatus/data.db";
      };
      ui = {
        title = "Status | dotsem.be";
        description = "Homelab Service Health";
        header = "Homelab Status";
      };
      endpoints = [
        {
          name = "Lobby Dashboard";
          group = "Core Infrastructure";
          url = "http://${hosts.lobby.ip}:8080";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "AdGuard Home";
          group = "Core Infrastructure";
          url = "http://${hosts.adguard-home.ip}:3000";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Battle Bus Ingress";
          group = "Core Infrastructure";
          url = "http://${hosts.battle-bus.ip}/healthz";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Grafana";
          group = "Observability";
          url = "http://${hosts.lonely-lodge.ip}:3000";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Prometheus";
          group = "Observability";
          url = "http://${hosts.lonely-lodge.ip}:9090/-/healthy";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "GoStrategy";
          group = "Applications";
          url = "https://gostrategy.dotsem.be";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Proxmox (Reboot Van)";
          group = "Hypervisors";
          url = "https://${hosts.reboot-van.ip}:8006";
          client = {
            insecure = true;
          };
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Proxmox (Supply Drop)";
          group = "Hypervisors";
          url = "https://${hosts.supply-drop.ip}:8006";
          client = {
            insecure = true;
          };
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
      ];
    };
  };
}
