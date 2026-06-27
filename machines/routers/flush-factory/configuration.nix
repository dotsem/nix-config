{ config, pkgs, lib, inputs, ips, ... }: {
  imports = [
    ../../../../common/core/default.nix
  ];

  # hardware and boot support from community flake
  boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor inputs.orangepi-3-lts-nixos.packages.aarch64-linux.linux);
  hardware.firmware = [ inputs.orangepi-3-lts-nixos.packages.aarch64-linux.firmware ];

  # override x86 grub/systemd-boot defaults
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.generic-extlinux-compatible.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  networking.hostName = "flush-factory";

  # disable ipv6 globally
  networking.enableIPv6 = false;

  # force predictable interface names off to keep eth0 naming stable
  networking.usePredictableInterfaceNames = false;

  # disable global dhcp client daemon
  networking.useDHCP = false;

  # network-on-a-stick vlan configuration
  networking.vlans = {
    vlan-wan = { id = 10; interface = "eth0"; };
    vlan-lan = { id = 20; interface = "eth0"; };
  };

  # wan interface uses dhcp to receive dynamic ip from isp
  networking.interfaces.vlan-wan.useDHCP = true;

  # lan interface uses static ip from global map
  networking.interfaces.vlan-lan.ipv4.addresses = [{
    address = ips.gateway;
    prefixLength = ips.prefixLength;
  }];

  # enable network packet forwarding
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;

  # router firewall using nftables
  networking.nftables = {
    enable = true;
    ruleset = ''
      table ip filter {
        chain input {
          type filter hook input priority 0; policy drop;
          ct state established,related accept
          ct state invalid drop
          iifname "lo" accept
          iifname "vlan-wan" udp dport 68 accept
          iifname "vlan-lan" accept
          ip protocol icmp accept
        }
        chain forward {
          type filter hook forward priority 0; policy drop;
          ct state established,related accept
          ct state invalid drop
          iifname "vlan-lan" oifname "vlan-wan" accept
        }
      }
      table ip nat {
        chain postrouting {
          type filter hook postrouting priority 100; policy accept;
          oifname "vlan-wan" masquerade
        }
      }
    '';
  };

  # dhcp and local dns resolver
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "vlan-lan";
      bind-interfaces = true;
      dhcp-range = "${ips.prefix}100,${ips.prefix}250,24h";
      dhcp-option = [
        "option:router,${ips.gateway}"
        "option:dns-server,${ips.gateway}"
        "option:netmask,255.255.255.0"
      ];
      dhcp-host = [
        "battlebus,${ips.devices.battlebus}"
        "rebootvan,${ips.devices.rebootvan}"
      ];
    };
  };
}
