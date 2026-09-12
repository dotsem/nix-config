{
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ../../../common/core/default.nix
    ../../../common/server/default.nix
  ];
}
