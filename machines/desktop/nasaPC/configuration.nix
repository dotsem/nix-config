{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../common/disko-config.nix
  ];

  networking.hostName = "nasaPC";

  # Machine specific packages or overrides
  environment.systemPackages = with pkgs; [
    steam
    vesktop
    # Add gaming specific tools here
  ];

  # Gaming tweaks
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  # Printing
  services.printing.enable = true;

  # Disko device override (uncomment and change if needed)
  # disko.devices.disk.main.device = "/dev/sda";
}
