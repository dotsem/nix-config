{ config, pkgs, ... }: {
  # Common hardware settings for desktops
  hardware.enableAllFirmware = true;
  
  # Graphics - Enable OpenGL (Standard names changed recently in nixpkgs)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Prevent USB audio devices (mics, DACs, headsets) from autosuspending
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="01", TEST=="../power/control", ATTR{../power/control}="on"
  '';
}
