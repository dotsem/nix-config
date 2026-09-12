{
  config,
  pkgs,
  lib,
  hosts,
  ...
}:
{
  services.grocy = {
    enable = true;
    hostName = "greasy-grove.home";
    nginx.enableSSL = false;
    settings = {
      currency = "EUR";
      culture = "nl";
      calendar = {
        firstDayOfWeek = 1; # monday
        showWeekNumber = true;
      };
      entryPage = "stock";
    };
    extraConfig = ''
      Setting("FEATURE_FLAG_CHORES", false);
      Setting("FEATURE_FLAG_TASKS", false);
      Setting("FEATURE_FLAG_BATTERIES", false);
      Setting("FEATURE_FLAG_EQUIPMENT", false);
      Setting("FEATURE_FLAG_CALENDAR", false);
      Setting("FEATURE_FLAG_STOCK_PRICE_TRACKING", false);
    '';
  };

  services.nginx.virtualHosts."${config.services.grocy.hostName}" = {
    default = true;
    serverAliases = [
      hosts.greasy-grove.ip
      "grocy.home"
      "localhost"
    ];
  };
}
