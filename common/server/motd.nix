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
    echo -e "\n\033[1;32mWelcome to ${config.networking.hostName}!\033[0m"
    echo -e "\033[1;34m${cfg.description}\033[0m\n"
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
