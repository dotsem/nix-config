{
  config,
  pkgs,
  lib,
  hosts,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ../../../common/core/default.nix
    ../../../common/server/default.nix
  ];

  # Requirement for NixOS configurations (even containers) to define a root filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos"; # Placeholder, overridden by LXC host
    fsType = "ext4";
  };

  networking.hostName = "lonely-lodge";

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.grafana_admin_password = {
    restartUnits = [ "logging-stack.service" ];
  };
  sops.templates."grafana-env".content = ''
    GRAFANA_PASSWORD=${config.sops.placeholder.grafana_admin_password}
  '';

  # Enable Docker for the logging stack
  virtualisation.docker.enable = true;
  users.users.sem.extraGroups = [ "docker" ];

  # Ensure the docker-compose and config files are present on the system
  environment.etc = {
    "logging/docker-compose.yml".source = ../../../docker/logging/docker-compose.yml;
    "logging/loki-config.yaml".source = ../../../docker/logging/loki-config.yaml;
    "logging/promtail-config.yaml".source = ../../../docker/logging/promtail-config.yaml;
    "logging/prometheus.yml".source = ../../../docker/logging/prometheus.yml;
    "logging/grafana/provisioning/dashboards/dashboards.yml".source = ../../../docker/logging/grafana/provisioning/dashboards/dashboards.yml;
    "logging/grafana/provisioning/datasources/datasources.yml".source = ../../../docker/logging/grafana/provisioning/datasources/datasources.yml;
    "logging/grafana/dashboards/gostrategy.json".source = ../../../docker/logging/grafana/dashboards/gostrategy.json;
    "logging/grafana/dashboards/server-snack.json".source = ../../../docker/logging/grafana/dashboards/server-snack.json;
  };

  # Systemd service to ensure the logging stack is running
  systemd.services.logging-stack = {
    description = "Grafana Loki Logging Stack";
    after = [
      "network-online.target"
      "docker.service"
      "sops-nix.service"
    ];
    wants = [
      "network-online.target"
      "docker.service"
      "sops-nix.service"
    ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [
      config.environment.etc."logging/docker-compose.yml".source
      config.environment.etc."logging/loki-config.yaml".source
      config.environment.etc."logging/promtail-config.yaml".source
      config.environment.etc."logging/prometheus.yml".source
      config.environment.etc."logging/grafana/provisioning/dashboards/dashboards.yml".source
      config.environment.etc."logging/grafana/provisioning/datasources/datasources.yml".source
      config.environment.etc."logging/grafana/dashboards/gostrategy.json".source
      config.environment.etc."logging/grafana/dashboards/server-snack.json".source
    ];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/etc/logging";
      EnvironmentFile = [ "-${config.sops.templates."grafana-env".path}" ];
      ExecStartPre = [
        # Ensure directories exist
        "${pkgs.coreutils}/bin/mkdir -p /logs/loki"
        "${pkgs.coreutils}/bin/mkdir -p /logs/grafana"
        "${pkgs.coreutils}/bin/mkdir -p /logs/prometheus"
        "${pkgs.coreutils}/bin/mkdir -p /logs/config"
        "${pkgs.coreutils}/bin/mkdir -p /logs/config/grafana"

        # Dereference symlinks using cp -rL into host-local stateful config partition
        "${pkgs.coreutils}/bin/rm -rf /logs/config/prometheus.yml /logs/config/grafana/provisioning /logs/config/grafana/dashboards"
        "${pkgs.coreutils}/bin/cp -rL /etc/logging/prometheus.yml /logs/config/prometheus.yml"
        "${pkgs.coreutils}/bin/cp -rL /etc/logging/grafana/provisioning /logs/config/grafana/provisioning"
        "${pkgs.coreutils}/bin/cp -rL /etc/logging/grafana/dashboards /logs/config/grafana/dashboards"

        # Ensure correct ownership permissions for container runs
        "${pkgs.coreutils}/bin/chown -R 10001:10001 /logs/loki"
        "${pkgs.coreutils}/bin/chown -R 472:472 /logs/grafana"
        "${pkgs.coreutils}/bin/chown -R 472:472 /logs/config/grafana"
        "${pkgs.coreutils}/bin/chown -R 65534:65534 /logs/prometheus"
        "${pkgs.coreutils}/bin/chown -R 65534:65534 /logs/config/prometheus.yml"
      ];
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up";
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
