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
    ../../../../common/core/default.nix
    ../../../../common/server/default.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "adguard-home";

  # Static IP configuration for LXC container
  networking.useDHCP = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = hosts.adguard-home.ip;
      prefixLength = hosts.adguard-home.prefixLength;
    }
  ];
  networking.defaultGateway = {
    address = hosts.adguard-home.gateway;
    interface = "eth0";
  };
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
        rewrites = [
          { domain = hosts.adguard-home.domain; answer = hosts.adguard-home.ip; enabled = true; }
          { domain = hosts.retail-row.domain; answer = hosts.retail-row.ip; enabled = true; }
          { domain = hosts.lonely-lodge.domain; answer = hosts.lonely-lodge.ip; enabled = true; }
        ];
      };
    };
  };

  # Open DNS (53) and HTTP Web Admin (80, 3000) ports
  networking.firewall.allowedTCPPorts = [ 53 80 3000 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
