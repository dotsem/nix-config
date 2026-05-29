{ config, pkgs, inputs, ... }: {
  imports = [
    ./desktop-environment.nix
    ./media.nix
    ./hardware.nix
    ./boot.nix
    ./services.nix
    ./packages.nix
    ./user.nix
  ];



  # Enable XDG portals
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ]; 
    config.common.default = "*";
  };
}
