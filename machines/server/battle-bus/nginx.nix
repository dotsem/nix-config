{
  config,
  pkgs,
  lib,
  hosts,
  ...
}:
let
  securityLocations = import ../../../lib/nginx-blocking.nix;
in
{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "_" = {
        default = true;
        rejectSSL = true;
        locations."/" = {
          return = "444";
        };
      };

      "battle-bus.home" = {
        serverAliases = [
          hosts.battle-bus.ip
          "localhost"
          "127.0.0.1"
        ];
        locations = securityLocations // {
          "/" = {
            return = "200 'Battle Bus Ingress Gateway Online\n'";
            extraConfig = "add_header Content-Type text/plain;";
          };
          "/healthz" = {
            return = "200 'OK\n'";
            extraConfig = "add_header Content-Type text/plain;";
          };
        };
      };

      "gostrategy.dotsem.be" = {
        locations = securityLocations // {
          # Frontend
          "/" = {
            proxyPass = "http://${hosts.retail-row.ip}:1000";
          };
          
          # Backend
          "/api/" = {
            proxyPass = "http://${hosts.retail-row.ip}:1001/";
          };
          "/ws/" = {
            proxyPass = "http://${hosts.retail-row.ip}:1001/";
            proxyWebsockets = true;
          };
          "/metrics" = {
            proxyPass = "http://${hosts.retail-row.ip}:1001/metrics";
            extraConfig = ''
              allow ${hosts.lonely-lodge.ip};
              deny all;
            '';
          };
        };
      };

      "wwb.dotsem.be" = {
        serverAliases = [
          "wwb.home"
        ];
        locations = securityLocations // {
          "/" = {
            proxyPass = "http://${hosts.retail-row.ip}:5000";
            proxyWebsockets = true;
          };
        };
      };

      "lobby.dotsem.be" = {
        serverAliases = [
          "lobby.home"
          hosts.lobby.ip
        ];
        locations = securityLocations // {
          "/assets/" = {
            alias = "${../lobby/assets}/";
            extraConfig = ''
              expires 30d;
              add_header Cache-Control "public, max-age=2592000, immutable";
            '';
          };
          "/" = {
            proxyPass = "http://${hosts.lobby.ip}:8080";
            proxyWebsockets = true;
          };
        };
      };

      "grafana.dotsem.be" = {
        locations = securityLocations // {
          "/" = {
            proxyPass = "http://${hosts.lonely-lodge.ip}:3000";
            proxyWebsockets = true;
          };
        };
      };

      "uptime.dotsem.be" = {
        locations = securityLocations // {
          "/" = {
            proxyPass = "http://${hosts.lobby.ip}:4000";
            proxyWebsockets = true;
          };
          "/internal" = {
            return = "301 https://uptime-internal.dotsem.be$request_uri";
          };
        };
      };

      "uptime-internal.dotsem.be" = {
        locations = securityLocations // {
          "/" = {
            proxyPass = "http://${hosts.lobby.ip}:4001";
            proxyWebsockets = true;
          };
        };
      };

      "uptime-stalker.dotsem.be" = {
        locations = securityLocations // {
          "/" = {
            proxyPass = "http://${hosts.lobby.ip}:4002";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
