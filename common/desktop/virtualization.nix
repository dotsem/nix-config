{ config, pkgs, ... }: {
  # Enable Docker daemon
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Enable Libvirtd (KVM/QEMU) virtualization for Android VMs and emulators
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_full;
      ovmf.enable = true;
      runAsRoot = false;
    };
  };

  # Enable Android Debug Bridge (ADB) - automatically configures android-udev rules globally
  programs.adb.enable = true;

  # Dynamically add the custom user to required virtualization and debugging groups
  users.users.${config.custom.username}.extraGroups = [
    "docker"
    "libvirtd"
    "adbusers"
  ];
}
