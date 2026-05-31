# This is a stub for the hardware configuration.
# Run 'nixos-generate-config' on the target machine and copy the content here.
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  # TODO: remove this once installing on a real machine
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "virtio_pci" "virtio_scsi" "virtio_blk" "ata_piix" ];
  boot.kernelModules = [ "kvm-intel" ]; # Or kvm-amd
  # ... rest of generated config
}
