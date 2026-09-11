{ hosts, ... }: {
  networking.nameservers = [
    hosts.adguard-home.ip
    hosts.adguard-home-zp.ip
    "1.1.1.1"
  ];
}