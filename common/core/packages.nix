{ config, pkgs }:
{
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    btop
    nettools
    pciutils
    usbutils
    unzip
    zip
    fastfetch
  ];
}
