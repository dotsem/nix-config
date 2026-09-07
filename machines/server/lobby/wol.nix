{
  config,
  pkgs,
  lib,
  ...
}:
let
  wakeDaemon = pkgs.buildGoModule {
    pname = "wake-daemon";
    version = "0.1.0";
    src = ../../../scripts/wake;
    vendorHash = null;
  };
in
{
  sops.secrets.wake_env = {
    restartUnits = [ "wol.service" ];
  };

  systemd.services.wol = {
    description = "Wake on LAN HTTP Daemon";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.wakeonlan ];

    serviceConfig = {
      ExecStart = "${wakeDaemon}/bin/wake";
      EnvironmentFile = config.sops.secrets.wake_env.path;
      Restart = "always";
      RestartSec = "5s";

      # Service hardening
      DynamicUser = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 9099 ];
}
