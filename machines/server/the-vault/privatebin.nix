{ ... }:
{
  services.privatebin = {
    enable = true;
    enableNginx = true;
    virtualHost = "privatebin.dotsem.be";
    settings = {
      main = {
        discussion = false;
        fileupload = false;
        burnafterreadingselected = true;
      };
      expire.default = "1day";
      # no "never" option, secrets must expire
      expire_options = {
        "5min" = 300;
        "1hour" = 3600;
        "1day" = 86400;
        "3days" = 259200;
        "1week" = 604800;
      };
    };
  };

  services.nginx.clientMaxBodySize = "10m";
}
