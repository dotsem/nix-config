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

    services = import ./homepage-services.nix { inherit hosts; };

    customCSS = builtins.readFile ./custom.css;
  };
}
