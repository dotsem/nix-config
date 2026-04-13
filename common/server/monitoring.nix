{
  config,
  pkgs,
  lib,
  ...
}:
{
  users.users.promtail.extraGroups = [ "docker" ];

  # Shipping logs to Loki on lonely-lodge
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 9081; # Use a non-standard port to avoid conflicts
        grpc_listen_port = 0;
      };
      clients = [
        {
          url = "http://192.168.200.6:3100/loki/api/v1/push";
        }
      ];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostName;
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
          ];
        }
      ]
      ++ (lib.optionals config.virtualisation.docker.enable [
        {
          job_name = "docker";
          docker_sd_configs = [ { host = "unix:///var/run/docker.sock"; } ];
          relabel_configs = [
            {
              source_labels = [ "__meta_docker_container_name" ];
              regex = "/(.*)";
              target_label = "container";
            }
            {
              source_labels = [ "__meta_docker_container_image" ];
              target_label = "image";
            }
          ];
        }
      ]);
    };
  };
}
