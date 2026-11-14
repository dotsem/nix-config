{
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ../../../common/core/default.nix
    ../../../common/server/default.nix
    ./privatebin.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "the-vault";

  sops.defaultSopsFile = ./secrets.yaml;

  networking.firewall.allowedTCPPorts = [
    22
    80
  ];
}
