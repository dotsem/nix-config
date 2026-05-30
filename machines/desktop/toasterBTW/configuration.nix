{ config, pkgs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../common/disko-config.nix
  ];

  networking.hostName = "toasterBTW";

  services.power-profiles-daemon.enable = false;
  services.upower.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      # Disable USB autosuspend — keeps peripherals always on
      USB_AUTOSUSPEND = 0;
      # Prevent phones from being power-managed by TLP
      USB_EXCLUDE_PHONE = 1;
      # Note: charging while lid-closed / sleeping is BIOS/EC-controlled, not TLP
    };
  };

  services.thermald.enable = true;
  services.libinput.enable = true;

  # Dynamic GPU Control: Nvidia proprietary drivers with PRIME offloading & D3cold power management
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}