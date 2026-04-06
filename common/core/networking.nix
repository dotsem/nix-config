{
  config,
  lib,
  ...
}:
{
  networking.networkmanager.enable = true;
  # Avoid rfkill/namespace errors in containers (LXC don't need WiFi)
  systemd.services.wpa_supplicant.enable = lib.mkIf config.boot.isContainer false;

  # Placeholder for firewall settings if needed
  networking.firewall.allowPing = true;
}
