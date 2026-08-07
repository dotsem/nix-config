# Single source of truth for all static machine IPs.
# Machines without fixed IPs are not listed here.
{
  adguard-home = { ip = "192.168.10.100"; domain = "adguard-home.home"; prefixLength = 24; gateway = "192.168.10.1"; };
  retail-row   = { ip = "192.168.10.102"; domain = "retail-row.home"; prefixLength = 24; gateway = "192.168.10.1"; };
  lonely-lodge = { ip = "192.168.10.103"; domain = "lonely-lodge.home"; prefixLength = 24; gateway = "192.168.10.1"; };
}
