{
  config,
  pkgs,
  lib,
  ...
}:
{
  boot.loader.efi.canTouchEfiVariables = lib.mkIf (!config.boot.isContainer) true;
  # Modern kernel for newer hardware (disabled in containers as they share the host kernel)
  boot.kernelPackages = lib.mkIf (!config.boot.isContainer) pkgs.linuxPackages_latest;
}
