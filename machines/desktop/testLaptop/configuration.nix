{ config, pkgs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../common/disko-config.nix
    ../../../common/desktop/laptop.nix
  ];

  networking.hostName = "testLaptop";

  # Target SATA SSD/HDD identified during live boot
  disko.devices.disk.main.device = "/dev/sda";

  # Prevent OOM crashes on 4GB RAM via in-memory compressed swap
  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  # Dynamic GPU Control: Nvidia proprietary drivers with PRIME offload
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.tailscale.enable = true;

  programs.steam.enable = true;
  programs.gamemode.enable = true;
}
