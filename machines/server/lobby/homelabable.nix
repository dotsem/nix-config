{
  config,
  pkgs,
  lib,
  hosts,
  ...
}:
{
  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.homepage_env.restartUnits = [
    "docker-homelabable-backend.service"
  ];

  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  systemd.services.docker-homelabable-network = {
    description = "Create Docker network for Homelabable";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network inspect homelabable-net >/dev/null 2>&1 || ${pkgs.docker}/bin/docker network create homelabable-net'";
    };
  };

  virtualisation.oci-containers.containers = {
    homelabable-backend = {
      image = "ghcr.io/pouzor/homelable-backend:latest";
      autoStart = true;
      environment = {
        SQLITE_PATH = "/app/data/homelab.db";
        AUTH_MODE = "local";
        AUTH_USERNAME = "admin";
        STATUS_CHECKER_INTERVAL = "60";
        SCANNER_RANGES = builtins.toJSON [
          "192.168.10.0/24"
          "192.168.0.0/24"
        ];
        CORS_ORIGINS = builtins.toJSON [
          "http://localhost:3000"
          "http://${hosts.lobby.ip}:3000"
          "https://homelabable.dotsem.be"
          "https://homelable.dotsem.be"
        ];
      };
      environmentFiles = [
        config.sops.secrets.homepage_env.path
      ];
      volumes = [
        "/var/lib/homelabable/data:/app/data"
      ];
      extraOptions = [
        "--network=homelabable-net"
        "--network-alias=backend"
        "--cap-add=NET_RAW"
      ];
    };

    homelabable-frontend = {
      image = "ghcr.io/pouzor/homelable-frontend:latest";
      autoStart = true;
      ports = [
        "3000:80"
      ];
      extraOptions = [
        "--network=homelabable-net"
      ];
      dependsOn = [
        "homelabable-backend"
      ];
    };
  };

  systemd.services.docker-homelabable-backend = {
    after = [ "docker-homelabable-network.service" ];
    requires = [ "docker-homelabable-network.service" ];
  };

  systemd.services.docker-homelabable-frontend = {
    after = [
      "docker-homelabable-network.service"
      "docker-homelabable-backend.service"
    ];
    requires = [ "docker-homelabable-network.service" ];
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}