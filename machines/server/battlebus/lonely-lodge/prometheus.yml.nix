{ pkgs, hosts }:
pkgs.writeText "prometheus.yml" ''
  global:
    scrape_interval: 15s
    evaluation_interval: 15s

  scrape_configs:
    - job_name: "gostrategy-backend"
      static_configs:
        - targets: ["${hosts.retail-row.ip}:80"]
      metrics_path: /metrics
''