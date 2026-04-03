{ config, pkgs, ... }: {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."stratego.dotsem.be" = {
      locations."/" = {
        proxyPass = "http://localhost:1000"; # Frontend
      };
      locations."/api/" = {
        proxyPass = "http://localhost:1001/"; # Backend
      };
      locations."/ws/" = {
        proxyPass = "http://localhost:1001/";
        proxyWebsockets = true;
      };
    };
  };
}
