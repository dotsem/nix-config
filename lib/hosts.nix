# Single source of truth for all static machine IPs.
# Machines without fixed IPs are not listed here.
{
  # proxmox hosts
  reboot-van = { ip = "192.168.10.10"; domain = "reboot-van.home"; prefixLength = 24; gateway = "192.168.10.1"; };
  supply-drop  = { ip = "192.168.10.11"; domain = "supply-drop.home"; prefixLength = 24; gateway = "192.168.10.1"; };
  zero-point = { ip = "192.168.10.12"; domain = "zero-point.home"; prefixLength = 24; gateway = "192.168.10.1"; };
  
  # vms & lxc'
  adguard-home = { ip = "192.168.10.100"; domain = "adguard-home.home"; prefixLength = 24; gateway = "192.168.10.1"; };
  lobby        = { ip = "192.168.10.101"; domain = "lobby.home"; prefixLength = 24; gateway = "192.168.10.1"; };
  retail-row   = { ip = "192.168.10.102"; domain = "retail-row.home"; prefixLength = 24; gateway = "192.168.10.1"; };
  lonely-lodge = { ip = "192.168.10.103"; domain = "lonely-lodge.home"; prefixLength = 24; gateway = "192.168.10.1"; };
  battle-bus   = { ip = "192.168.10.104"; domain = "battle-bus.home"; prefixLength = 24; gateway = "192.168.10.1"; };
  tailscale    = { ip = "192.168.10.110"; domain = "tailscale.home"; prefixLength = 24; gateway = "192.168.10.1"; };

  # network hardware
  openwrt        = { ip = "192.168.0.167"; };
  netgear-switch = { ip = "192.168.0.11"; };
}
