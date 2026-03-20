{ config, ... }: {
  networking.networkmanager.enable = true;
  # Placeholder for firewall settings if needed
  networking.firewall.allowPing = true;
}
