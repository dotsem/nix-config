{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ../../../../common/core/default.nix
    ../../../../common/server/default.nix
  ];

  # Requirement for NixOS configurations (even containers) to define a root filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos"; # Placeholder, overridden by LXC host
    fsType = "ext4";
  };

  networking.hostName = "lonely-lodge";

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.grafana_admin_password = {};

  # Enable Docker for the logging stack
  virtualisation.docker.enable = true;
  users.users.sem.extraGroups = [ "docker" ];

  # Ensure the docker-compose and config files are present on the system
  environment.etc = {
    "logging/docker-compose.yml".source = ./../../../../docker/logging/docker-compose.yml;
    "logging/loki-config.yaml".source = ./../../../../docker/logging/loki-config.yaml;
    "logging/promtail-config.yaml".source = ./../../../../docker/logging/promtail-config.yaml;
    "logging/prometheus.yml".source = ./../../../../docker/logging/prometheus.yml;
    "logging/grafana/provisioning/dashboards/dashboards.yml".source = ./../../../../docker/logging/grafana/provisioning/dashboards/dashboards.yml;
    "logging/grafana/provisioning/datasources/datasources.yml".source = ./../../../../docker/logging/grafana/provisioning/datasources/datasources.yml;
    "logging/grafana/dashboards/gostrategy.json".source = ./../../../../docker/logging/grafana/dashboards/gostrategy.json;
  };

  # Systemd service to ensure the logging stack is running
  systemd.services.logging-stack = {
    description = "Grafana Loki Logging Stack";
    after = [
      "network-online.target"
      "docker.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/etc/logging";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p /logging/loki"
        "${pkgs.coreutils}/bin/mkdir -p /logging/grafana"
        "${pkgs.coreutils}/bin/mkdir -p /logging/prometheus"
        "${pkgs.coreutils}/bin/chown -R 10001:10001 /logging/loki"
        "${pkgs.coreutils}/bin/chown -R 472:472 /logging/grafana"
        "${pkgs.coreutils}/bin/chown -R 65534:65534 /logging/prometheus"
      ];
      ExecStart = "${pkgs.bash}/bin/bash -c 'GRAFANA_PASSWORD=$(cat ${config.sops.secrets.grafana_admin_password.path}) ${pkgs.docker-compose}/bin/docker-compose up'";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
      Restart = "always";
    };
  };

  # Open ports for Loki (3100), Grafana (3000), and Prometheus (9090)
  networking.firewall.allowedTCPPorts = [
    3000
    3100
    9090
  ];

  # LXC specific adjustment if needed (hostname usually inherited, but explicit is better)
  # networking.useDHCP = lib.mkDefault true;
}
