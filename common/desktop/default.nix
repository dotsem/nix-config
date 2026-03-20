{ config, pkgs, inputs, ... }: {
  imports = [
    ./desktop-environment.nix
    ./media.nix
    ./hardware.nix
    ./boot.nix
  ];

  # Basic desktop packages
  environment.systemPackages = with pkgs; [
    alacritty 
    firefox
    libnotify
    wl-clipboard
    grim
    slurp
    swaybg
  ];

  # Enable XDG portals
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ]; 
    config.common.default = "*";
  };
}
