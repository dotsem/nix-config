# This is a stub for the hardware configuration.
# Run 'nixos-generate-config' on the target machine and copy the content here.
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ]; # Or kvm-intel
  # ... rest of generated config
}
