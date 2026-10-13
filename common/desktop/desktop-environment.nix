{ config, pkgs, inputs, ... }: {
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Niri — primary compositor
  programs.niri.enable = true;

  # KDE Plasma 6 — fallback session
  services.desktopManager.plasma6.enable = true;

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
