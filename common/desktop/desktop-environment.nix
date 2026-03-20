{ config, pkgs, inputs, ... }: {
  # Greater
  services.displayManager.sddm.enable = true; 

  # Niri (default)
  programs.niri.enable = true;

  environment.systemPackages = [
    inputs.dms.packages.${pkgs.system}.default
  ];

  # Hyprland
  programs.hyprland.enable = true;

  # Sway
  programs.sway.enable = true;

  # KDE Plasma
  services.desktopManager.plasma6.enable = true;
}
