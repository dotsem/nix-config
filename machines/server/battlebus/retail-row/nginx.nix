{ config, pkgs, ... }:
let
  securityLocations = import ../../../../common/server/nginx-hardening.nix;
in {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."gostrategy.dotsem.be" = {
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
      };
    };
  };
}
