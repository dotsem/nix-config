{ config, lib, ... }: {
  networking.networkmanager.enable = lib.mkDefault (!config.boot.isContainer);
  # wpa_supplicant is irrelevant inside LXC containers
  systemd.services.wpa_supplicant.enable = lib.mkIf config.boot.isContainer false;
}
