{
  config,
  lib,
  ...
}:
let
  docker = config.virtualisation.docker.enable;
in
{
  # System metrics exporter for Prometheus
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "systemd" ];
    port = 9100;
    openFirewall = true;
  };

  # Shipping logs to Loki on lonely-lodge. Alloy replaces promtail, which was removed in 26.05 (EOL).
  services.alloy.enable = true;
  # unit uses DynamicUser, so docker socket access goes via supplementary group
  systemd.services.alloy.serviceConfig.SupplementaryGroups = lib.mkIf docker [ "docker" ];

  environment.etc."alloy/config.alloy".text = ''
    loki.write "default" {
      endpoint {
        url = "http://lonely-lodge.home:3100/loki/api/v1/push"
      }
    }

    loki.relabel "journal" {
      forward_to = []
      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
    }

    loki.source.journal "journal" {
      max_age       = "12h"
      relabel_rules = loki.relabel.journal.rules
      labels        = {
        job  = "systemd-journal",
        host = "${config.networking.hostName}",
      }
      forward_to    = [loki.write.default.receiver]
    }
  ''
  + lib.optionalString docker ''

    discovery.docker "containers" {
      host = "unix:///var/run/docker.sock"
    }

    loki.relabel "docker" {
      forward_to = []
      rule {
        source_labels = ["__meta_docker_container_name"]
        regex         = "/(.*)"
        target_label  = "container"
      }
      rule {
        source_labels = ["__meta_docker_container_image"]
        target_label  = "image"
      }
    }

    loki.source.docker "containers" {
      host          = "unix:///var/run/docker.sock"
      targets       = discovery.docker.containers.targets
      relabel_rules = loki.relabel.docker.rules
      forward_to    = [loki.process.docker.receiver]
    }

    loki.process "docker" {
      stage.regex {
        expression = `.*\[(?P<level>[A-Z ]+)\].*`
      }
      stage.labels {
        values = { level = "" }
      }
      stage.match {
        selector = `{container="gostrategy-backend"} |= "[SECURITY]"`
        stage.static_labels {
          values = { security_event = "true" }
        }
      }
      forward_to = [loki.write.default.receiver]
    }
  '';
}
