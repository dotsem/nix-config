{ config, pkgs, ... }: {
  users.users.sem = {
    isNormalUser = true;
    # docker is declared in desktop/virtualization.nix; servers declare it locally
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "lp" "scanner" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNrpS0BG9BshjujiJ3KP/g04LIJFT9ZQ0cSYCuM4HKi sem@toasterBTW"
    ];
    hashedPassword = "$6$3U2G7TDA2NQY.Z9Y$ZvMhe.iXhuvCFrukJKilu.VUBGSfW4u8LVaqDuBrSG3eb2D2ama2/99uiIvQJPQyrhE5mI.RYyv6WLy9TKQ411";
  };

  programs.fish.enable = true;
}

