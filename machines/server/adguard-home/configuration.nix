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

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "adguard-home";

  sops.defaultSopsFile = ./secrets.yaml;

  networking.nameservers = lib.mkForce [ "1.1.1.1" ];

  # Disable systemd-resolved so AdGuard Home can bind to port 53
  services.resolved.enable = false;

  # Enable AdGuard Home
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    settings = {
      http = {
        address = "0.0.0.0:3000";
      };
      dns = {
        bind_hosts = [ "0.0.0.0" ];
        port = 53;
        bootstrap_dns = [
          "9.9.9.9"
          "1.1.1.1"
        ];
        upstream_dns = [
          "https://cloudflare-dns.com/dns-query"
          "https://dns.quad9.net/dns-query"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        rewrites_enabled = true;
        parental_enabled = false;
        safe_search = {
          enabled = false;
        };
        rewrites = lib.mapAttrsToList (name: host: {
          domain = host.domain;
          answer = host.ip;
          enabled = true;
        })  (lib.filterAttrs (_: host: host ? domain) hosts);
      };
      filters = map (url: { enabled = true; inherit url; }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"  # AdGuard DNS Filter
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_7.txt"  # Smart-TV Blocklist
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # URLhaus Malicious URLs
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt" # Dandelion Sprout's Anti-Malware
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt" # Phishing URL Blocklist
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_48.txt" # HaGeZi Multi PRO
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_52.txt" # HaGeZi Encrypted DNS Bypass
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_63.txt" # HaGeZi Windows/Office Tracker
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_67.txt" # HaGeZi Apple Tracker
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_71.txt" # HaGeZi DNS Rebind Protection
      ];
    };
  };

  # Open DNS (53) and HTTP Web Admin (80, 3000) ports
  networking.firewall.allowedTCPPorts = [ 53 80 3000 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
