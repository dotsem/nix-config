{ config, pkgs, lib, ... }: {
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  services.thermald.enable = lib.mkDefault true;

  # Thunderbolt / USB4 dock daemon
  services.hardware.bolt.enable = true;

  # Periodic NVMe SSD TRIM
  services.fstrim.enable = true;

  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = false;
      tapping = true;
      disableWhileTyping = true;
      clickMethod = "clickfinger";
    };
  };

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
  };

  # Transition from sleep to persistent disk hibernation after 1 hour
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "1h";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
    HandlePowerKey = "suspend-then-hibernate";
    IdleAction = "suspend-then-hibernate";
    IdleActionSec = "1h";
  };
}
