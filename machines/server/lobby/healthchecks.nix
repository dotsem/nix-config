{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets.healthchecks_ping_url = { };

  sops.templates."healthchecks-env".content = ''
    PING_URL=${config.sops.placeholder.healthchecks_ping_url}
  '';

  systemd.services.healthchecks-ping = {
    description = "Healthchecks.io Heartbeat Ping";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = config.sops.templates."healthchecks-env".path;
      ExecStart = "${pkgs.curl}/bin/curl -fsS --retry 3 \${PING_URL}";
      DynamicUser = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
    };
  };

  systemd.timers.healthchecks-ping = {
    description = "Run Healthchecks.io heartbeat ping every minute";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "1m";
    };
  };
}
