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

  networking.hostName = "tailscale";

  networking.useDHCP = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = hosts.tailscale.ip;
      prefixLength = hosts.tailscale.prefixLength;
    }
  ];
  networking.defaultGateway = {
    address = hosts.tailscale.gateway;
    interface = "eth0";
  };

  # Enable Kernel IP forwarding (required for Subnet Routing and Exit Node functionality)
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Enable Tailscale daemon
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both"; # Allows client to act as subnet router and exit node
    openFirewall = true;
  };

  # Ensure UDP 41641 (Tailscale WireGuard default port) is allowed
  networking.firewall.allowedUDPPorts = [ 41641 ];
}
