{ config, pkgs, ... }: {
  # Common hardware settings for desktops
  hardware.enableAllFirmware = true;
  
  # Graphics - Enable OpenGL (Standard names changed recently in nixpkgs)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
