{ config, pkgs, inputs, ... }: {
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Niri — primary compositor
  programs.niri.enable = true;

  # KDE Plasma 6 — fallback session
  services.desktopManager.plasma6.enable = true;

  # DankMaterialShell shell layer
  environment.systemPackages = [
    inputs.dms.packages.${pkgs.system}.default
  ];
}
