{ config, pkgs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../common/disko-config.nix
    ../../../common/desktop/laptop.nix
  ];

  networking.hostName = "toasterBTW";

  disko.devices.disk.main.device = "/dev/nvme0n1";
  custom.disko.swap.enable = true;

  # Acer EC throttling mitigation
  services.throttled = {
    enable = true;
    extraConfig = ''
      [GENERAL]
      Enabled: True
      Sysfs_Power_Path: /sys/class/power_supply/AC*/online
      Autoreload: True

      [AC]
      Update_Rate_s: 5
      PL1_Tdp_W: 25
      PL1_Duration_s: 28
      PL2_Tdp_W: 40
      PL2_Duration_S: 0.002
      Trip_Temp_C: 85
      cTDP: 0
      Disable_BDPROCHOT: False

      [BATTERY]
      Update_Rate_s: 30
      PL1_Tdp_W: 15
      PL1_Duration_s: 28
      PL2_Tdp_W: 30
      PL2_Duration_s: 0.002
      Trip_Temp_C: 80
      Disable_BD_PROCHOT: False
    '';
  };

  # Nvidia PRIME offload with D3cold power management
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