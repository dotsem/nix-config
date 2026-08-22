{
  config,
  pkgs,
  lib,
  ...
}:
{
  virtualisation.docker.enable = true;
  users.users.sem.extraGroups = [ "docker" ];

  environment.etc."kitchenowl/docker-compose.yml".source = ../../../docker/kitchenowl/docker-compose.yml;

  systemd.services.kitchenowl = {
    description = "KitchenOwl Grocery & Recipe Stack";
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
      config.environment.etc."kitchenowl/docker-compose.yml".source
    ];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/etc/kitchenowl";
      EnvironmentFile = [ "-${config.sops.templates."kitchenowl-env".path}" ];
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p /var/lib/kitchenowl/data"
      ];
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
      Restart = "always";
    };
  };
}
