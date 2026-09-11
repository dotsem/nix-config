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
    settings = {
      currency = "EUR";
      culture = "en";
      calendar = {
        firstDayOfWeek = 1; # monday
        showWeekNumber = true;
      };
      entryPage = "stock";
    };
  };

  # allow direct ip access and alternative hostnames
  services.nginx.virtualHosts."${config.services.grocy.hostName}" = {
    default = true;
    serverAliases = [
      hosts.greasy-grove.ip
      "grocy.home"
      "localhost"
    ];
  };
}
