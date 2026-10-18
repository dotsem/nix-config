{ config, pkgs, inputs, ... }: {
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  services.displayManager.gdm.enable = true;

  # Niri — primary compositor
  programs.niri.enable = true;

  # GNOME — fallback session
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
    totem
    gnome-music
    gnome-contacts
    gnome-weather
    gnome-maps
  ];

  # Noctalia Wayland shell (v5)
  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemd.enable = true;
    recommendedServices.enable = true;
  };

  environment.systemPackages = [
    pkgs.xwayland-satellite
  ];
}
