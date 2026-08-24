{
  config,
  pkgs,
  lib,
  hosts,
  ...
}:
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.dotsem.be";
      listen-http = ":8090";
      behind-proxy = true;
      auth-default-access = "deny-all";
      upstream-base-url = "https://ntfy.sh";
    };
  };
}
