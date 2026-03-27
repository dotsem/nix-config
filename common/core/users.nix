{ config, pkgs, ... }: {
  users.users.sem = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "lp" "scanner" "docker" ];
    shell = pkgs.fish; 
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNrpS0BG9BshjujiJ3KP/g04LIJFT9ZQ0cSYCuM4HKi sem@toasterBTW"
    ];
  };

  users.users.sem.initialPassword = "blub";

  programs.fish.enable = true;
}
