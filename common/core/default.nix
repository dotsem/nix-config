{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./vars.nix
    ./nix.nix
    ./users.nix
    ./networking.nix
    ./boot-generic.nix
    ./packages.nix
    ./git.nix
    ./security.nix
    ./dotfiles-setup.nix
    ./sops.nix
  ];

  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "be-latin1";

  services.fstrim.enable = true;

  # cap journal to prevent log runaway on long-lived installs
  services.journald.extraConfig = "SystemMaxUse=100M";

  system.stateVersion = "25.11";
}
