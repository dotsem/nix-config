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



  # Enable XDG portals
  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-gnome 
      pkgs.kdePackages.xdg-desktop-portal-kde
    ]; 
    config = {
      common = {
        default = [ "gnome" ];
      };
      niri = {
        default = [ "gnome" ];
      };
      kde = {
        default = [ "kde" ];
      };
    };
  };
}
