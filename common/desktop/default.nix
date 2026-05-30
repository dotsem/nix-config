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

  # Required for hardware.enableAllFirmware and unfree packages (vscode, nvidia, etc.)
  nixpkgs.config.allowUnfree = true;

  # XDG portals: gnome portal is required by niri, kde portal handles plasma sessions
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
    config = {
      common.default = [ "gnome" ];
      kde.default = [ "kde" ];
    };
  };

  # Polkit agent for niri sessions (plasma provides its own agent)
  security.soteria.enable = true;

  # Keyring daemon — enables browser/app secret storage and auto-unlock on login
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Bluetooth manager service (the blueman package alone does nothing without this)
  services.blueman.enable = true;
}
