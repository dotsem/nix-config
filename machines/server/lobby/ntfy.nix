{
  config,
  pkgs,
  lib,
  hosts,
  inputs,
  ...
}:
{
  services.ntfy-sh = {
    enable = true;
    package = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.ntfy-sh;
    settings = {
      base-url = "https://ntfy.dotsem.be";
      listen-http = ":8090";
      behind-proxy = true;
      auth-default-access = "deny-all";
      upstream-base-url = "https://ntfy.sh";
    };
  };
}
