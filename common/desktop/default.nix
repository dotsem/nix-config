{ config, pkgs, inputs, ... }: {
  imports = [
    ./desktop-environment.nix
    ./media.nix
    ./hardware.nix
    ./boot.nix
    ./services.nix
    ./packages.nix
    ./user.nix
    ./fonts.nix
    ./virtualization.nix
  ];

  # Desktops grant wheel users nix daemon trust
  nix.settings.trusted-users = [ "root" "@wheel" ];

  custom.isDesktop = true;

  # Required for hardware.enableAllFirmware and unfree packages (vscode, nvidia, etc.)
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];

  nixpkgs.overlays = [
    (import ../../pkgs)
  ];

  # XDG portals: gnome portal handles screencast and desktop integration for niri and gnome
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
    ];
    config = {
      common.default = [ "gnome" ];
    };
  };

  # Polkit agent for niri sessions (gnome provides its own agent)
  security.soteria.enable = true;

  # Keyring daemon — enables browser/app secret storage and auto-unlock on login
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Unify Qt application styling with GNOME dark mode
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  # Bluetooth manager service (the blueman package alone does nothing without this)
  services.blueman.enable = true;
}
