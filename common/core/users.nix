{ config, pkgs, ... }: {
  users.users.sem = {
    isNormalUser = true;
    # docker is declared in desktop/virtualization.nix; servers declare it locally
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "lp" "scanner" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNrpS0BG9BshjujiJ3KP/g04LIJFT9ZQ0cSYCuM4HKi sem@toasterBTW"
    ];
    # Set password manually on first boot via: passwd sem
  };

  programs.fish.enable = true;
}

