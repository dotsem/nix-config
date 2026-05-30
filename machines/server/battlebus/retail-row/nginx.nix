{ config, pkgs, ... }: {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."gostrategy.dotsem.be" = {
      locations."~ /\\.(?!well-known(/|$))" = {
        return = "404";
      };

      locations."~* \\.(env|key|pem|pypirc|bak|config|sql|yaml|yml)(;|/|$)" = {
        return = "404";
      };

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
