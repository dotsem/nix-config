{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../common/disko-config.nix
  ];

  networking.hostName = "toasterBTW";

  # Better battery life on laptop
  services.tlp.enable = true;
  services.upower.enable = true;

  # Power profiles
  services.thermald.enable = true;

  # Touchpad support
  services.libinput.enable = true;

  # Laptop specific packages
  environment.systemPackages = with pkgs; [
    brightnessctl
    playerctl
  ];

  # Disko device override (uncomment and change if needed)
  # disko.devices.disk.main.device = "/dev/sda";
}