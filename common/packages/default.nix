{ config, ... }: {
  imports = [
    ./programming.nix
    ./desktop.nix
    ./system.nix
  ];
}
