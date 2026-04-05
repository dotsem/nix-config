{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../../../common/core/default.nix
    ../../../../common/server/default.nix
  ];

  networking.hostName = "lonely-lodge";

  # Enable Docker for the logging stack
  virtualisation.docker.enable = true;
  users.users.sem.extraGroups = [ "docker" ];

  # Systemd service to ensure the logging stack is running
  systemd.services.logging-stack = {
    description = "Grafana Loki Logging Stack";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/home/sem/nix-config/docker/logging";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
      Restart = "always";
    };
  };

  # Open ports for Loki (3100) and Grafana (3000)
  networking.firewall.allowedTCPPorts = [
    3000
    3100
  ];

  # LXC specific adjustment if needed (hostname usually inherited, but explicit is better)
  # networking.useDHCP = lib.mkDefault true;
}
