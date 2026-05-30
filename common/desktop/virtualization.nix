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
      runAsRoot = false;
    };
  };

  environment.systemPackages = with pkgs; [
    android-tools
  ];

  # Dynamically add the custom user to required virtualization groups
  users.users.${config.custom.username}.extraGroups = [
    "docker"
    "libvirtd"
  ];
}
