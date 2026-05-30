{ config, pkgs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../common/disko-config.nix
  ];

  networking.hostName = "toasterBTW";

  # Better battery life on laptop with fine-tuned USB settings
  services.power-profiles-daemon.enable = false;
  services.upower.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      # Disable USB autosuspend entirely (ensures consistent device connection)
      USB_AUTOSUSPEND = 0;
      # Exclude phones/smartphones from power saving rules
      USB_EXCLUDE_PHONE = 1;
      # Keep USB ports powered on AC and Battery transitions
      USB_AUTOSUSPEND_ON_AC = "off";
      USB_AUTOSUSPEND_ON_BAT = "off";
    };
  };

  # Power profiles
  services.thermald.enable = true;

  # Touchpad support
  services.libinput.enable = true;

  # Laptop specific packages
  environment.systemPackages = with pkgs; [
    brightnessctl
    playerctl
  ];

  # Dynamic GPU Control: Nvidia proprietary drivers with PRIME offloading & D3cold power management
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true; # Automatically power down GPU to D3cold (0W draw) when not in use
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Standard laptop Bus IDs (update if different on your hardware)
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}