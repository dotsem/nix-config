{ config, pkgs, hosts, ... }:
let
  securityLocations = import ../../../../common/server/nginx-blocking.nix;
in {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."gostrategy.dotsem.be" = {
      serverAliases = [ hosts.retail-row.ip "retail-row.home" ];
      locations = securityLocations // {
        "/" = {
          proxyPass = "http://localhost:1000"; # Frontend
        };
        "/api/" = {
          proxyPass = "http://localhost:1001/"; # Backend
        };
        "/ws/" = {
          proxyPass = "http://localhost:1001/";
          proxyWebsockets = true;
        };
        "/metrics" = {
          proxyPass = "http://localhost:1001/metrics";
          extraConfig = ''
            allow ${hosts.lonely-lodge.ip};
            deny all;
          '';
        };
      };
    };
  };
}
