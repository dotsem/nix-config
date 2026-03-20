{ config, pkgs, ... }: {
  users.users.sem = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "lp" "scanner" "docker" ];
    shell = pkgs.fish; 
  };

  programs.fish.enable = true;
}
