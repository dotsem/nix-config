{ config, pkgs, inputs, ... }: {
  # SDDM Display Manager
  services.displayManager.sddm.enable = true; 

  # Niri (Wayland compositor)
  programs.niri.enable = true;

  environment.systemPackages = [
    inputs.dms.packages.${pkgs.system}.default
  ];

  # Hyprland
  # programs.hyprland.enable = true;

  # Sway
  # programs.sway.enable = true;

  # KDE Plasma6
  services.desktopManager.plasma6.enable = true;
}

