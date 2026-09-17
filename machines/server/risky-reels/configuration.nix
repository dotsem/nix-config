{
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ../../../common/core/default.nix
    ../../../common/server/default.nix
    ./jellyfin.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "risky-reels";

  sops.defaultSopsFile = ./secrets.yaml;

  environment.systemPackages = with pkgs; [
    curl
    vim
    tmux
  ];

  networking.firewall.allowedTCPPorts = [
    22
  ];

  # Jellyfin client auto-discovery and DLNA ports
  networking.firewall.allowedUDPPorts = [
    1900
    7359
  ];
}
