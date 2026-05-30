{
  config,
  pkgs,
  lib,
  ...
}:
{
  boot.loader.systemd-boot.enable = lib.mkIf (!config.boot.isContainer && !config.boot.loader.refind.enable) true;
  boot.loader.efi.canTouchEfiVariables = lib.mkIf (!config.boot.isContainer) true;
  boot.loader.grub.enable = false;
  # Modern kernel for newer hardware (disabled in containers as they share the host kernel)
  boot.kernelPackages = lib.mkIf (!config.boot.isContainer) pkgs.linuxPackages_latest;
}
