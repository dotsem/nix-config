{ config, pkgs, ... }:
let
  keys = import ../../lib/keys.nix;
in
{
  users.users.sem = {
    isNormalUser = true;
    # docker is declared in desktop/virtualization.nix; servers declare it locally
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "lp" "scanner" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [ keys.toasterBTW ];
    hashedPassword = "$6$3U2G7TDA2NQY.Z9Y$ZvMhe.iXhuvCFrukJKilu.VUBGSfW4u8LVaqDuBrSG3eb2D2ama2/99uiIvQJPQyrhE5mI.RYyv6WLy9TKQ411";
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [ keys.toasterBTW ];
  };

  programs.fish.enable = true;
}

