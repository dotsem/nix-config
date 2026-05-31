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
    pkgs.quickshell
    pkgs.xwayland-satellite
  ];

  # Register the systemd service from the dms package
  systemd.packages = [ inputs.dms.packages.${pkgs.system}.default ];

  # Enable the user service for the graphical session
  systemd.user.services.dms = {
    wantedBy = [ "graphical-session.target" ];
  };
}
