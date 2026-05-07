{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.custom.server;
  motdScript = pkgs.writeShellScript "motd.sh" ''
    ${pkgs.fastfetch}/bin/fastfetch
    printf "\n\033[1;32mWelcome to %s!\033[0m\n" "${config.networking.hostName}"
    printf "\033[1;34m%s\033[0m\n\n" "${cfg.description}"
  '';
in
{
  options.custom.server = {
    description = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "a description of the server for the motd";
    };
  };

  config = lib.mkIf (cfg.description != null) {
    users.motd = ""; # disable static motd

    environment.interactiveShellInit = ''
      if [[ $- == *i* && -z "$MOTD_SHOWN" ]]; then
        export MOTD_SHOWN=1
        ${motdScript}
      fi
    '';

    programs.fish.interactiveShellInit = lib.mkIf config.programs.fish.enable ''
      if status is-interactive; and not set -q MOTD_SHOWN
        set -gx MOTD_SHOWN 1
        ${motdScript}
      end
    '';
  };
}
