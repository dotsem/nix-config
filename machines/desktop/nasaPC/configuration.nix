{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../common/disko-config.nix
  ];

  networking.hostName = "nasaPC";

  # Max Performance Optimization
  powerManagement.cpuFreqGovernor = "performance";

  # Machine specific packages or overrides
  environment.systemPackages = with pkgs; [
    steam
    vesktop
  ];

  # Gaming tweaks
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  # Enable Nvidia proprietary drivers for maximum gaming performance
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false; # Not required on desktops
    open = false; # Use stable proprietary driver
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Early loading modules in initramfs for crisp, flicker-free boot
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  # Printing
  services.printing.enable = true;
}
