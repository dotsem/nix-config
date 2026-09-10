{ hosts, ... }: {
  networking.nameservers = [
    hosts.adguard-home.ip
    "1.1.1.1"
  ];
}