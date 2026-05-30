{ config, lib, ... }: {
  networking.networkmanager.enable = true;
  # wpa_supplicant is irrelevant inside LXC containers
  systemd.services.wpa_supplicant.enable = lib.mkIf config.boot.isContainer false;
}
