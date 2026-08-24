{
  config,
  pkgs,
  lib,
  hosts,
  ...
}:
let
  yaml = pkgs.formats.yaml { };

  defaultAlerts = [
    {
      type = "ntfy";
      failure-threshold = 3;
      success-threshold = 2;
      send-on-resolved = true;
    }
  ];

  withAlerts = endpoints: map (e: e // { alerts = defaultAlerts; }) endpoints;

  mkGatusService =
    {
      name,
      port,
      title,
      header,
      endpoints,
      enableAlerting ? true,
    }:
    let
      settings = {
        web.port = port;
        storage = {
          type = "sqlite";
          path = "/var/lib/${name}/data.db";
        };
        ui = {
          inherit title header;
          description = "Service Health Status";
        };
        alerting = lib.optionalAttrs enableAlerting {
          ntfy = {
            url = "http://127.0.0.1:8090";
            topic = "alerts";
            priority = 4;
          };
        };
        inherit endpoints;
      };
      configFile = yaml.generate "${name}.yaml" settings;
    in
    {
      description = "Gatus service - ${name}";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        GATUS_CONFIG_PATH = "${configFile}";
      };
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        User = name;
        Group = name;
        Restart = "on-failure";
        ExecStart = "${pkgs.gatus}/bin/gatus";
        StateDirectory = name;
        SyslogIdentifier = name;
        AmbientCapabilities = "CAP_NET_RAW";
        CapabilityBoundingSet = "CAP_NET_RAW";
        NoNewPrivileges = true;
      };
    };

  instances = {
    gatus-public = {
      name = "gatus-public";
      port = 4000;
      title = "Public Status | dotsem.be";
      header = "Public Projects | dotsem.be";
      endpoints = withAlerts [
        {
          name = "World Wide Bulb";
          group = "Projects";
          url = "https://wwb.dotsem.be";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "GoStrategy";
          group = "Projects";
          url = "https://gostrategy.dotsem.be";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Portfolio";
          group = "Projects";
          url = "https://dotsem.be";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Weighted Decision Maker";
          group = "Projects";
          url = "https://dotsem.github.io/Weighted-Decision-Matrix/";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Chez Natalie";
          group = "Projects";
          url = "https://cheznatalie.tiboit.be";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
      ];
    };

    gatus-internal = {
      name = "gatus-internal";
      port = 4001;
      title = "Internal Status | dotsem.be";
      header = "Homelab Infrastructure";
      endpoints = withAlerts [
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
          name = "Proxmox (Reboot Van)";
          group = "Hypervisors";
          url = "https://${hosts.reboot-van.ip}:8006";
          client.insecure = true;
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Proxmox (Supply Drop)";
          group = "Hypervisors";
          url = "https://${hosts.supply-drop.ip}:8006";
          client.insecure = true;
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Proxmox (Zero Point)";
          group = "Hypervisors";
          url = "https://${hosts.zero-point.ip}:8006";
          client.insecure = true;
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
      ];
    };

    gatus-stalker = {
      name = "gatus-stalker";
      port = 4002;
      title = "Stalker Status | dotsem.be";
      header = "External Websites | dotsem.be";
      enableAlerting = false;
      endpoints = [
        {
          name = "Cloudflare DNS";
          group = "External DNS";
          url = "https://1.1.1.1";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "GitHub";
          group = "External Services";
          url = "https://github.com";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Orca Bree";
          url = "https://orca-bree.be";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
      ];
    };
  };
in
{
  systemd.services = lib.mapAttrs (name: cfg: mkGatusService cfg) instances;

  networking.firewall.allowedTCPPorts = [
    4000
    4001
    4002
  ];
}
