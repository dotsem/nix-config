{ config, pkgs, lib, ... }: {
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  services.thermald.enable = lib.mkDefault true;

  # Thunderbolt / USB4 dock daemon
  services.hardware.bolt.enable = true;

  # Periodic NVMe SSD TRIM
  services.fstrim.enable = true;

  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = false;
      tapping = true;
      disableWhileTyping = true;
      clickMethod = "clickfinger";
    };
  };

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
  };
}
