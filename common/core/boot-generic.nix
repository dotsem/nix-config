{ config, pkgs, ... }: {
  boot.loader.efi.canTouchEfiVariables = true;
  # Modern kernel for newer hardware
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
