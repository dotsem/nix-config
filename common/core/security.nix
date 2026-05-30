{ config, pkgs, ... }: {
  # Enable built-in NixOS firewall (equivalent to UFW setup)
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ]; # Allow SSH
    allowPing = true;
  };

  # Enable fail2ban for automated intrusion prevention
  services.fail2ban.enable = true;
}
