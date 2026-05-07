{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./nix.nix
    ./users.nix
    ./networking.nix
    ./boot-generic.nix
    ./packages.nix
  ];

  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "be-latin1";

  system.stateVersion = "25.11"; # Updated to current stable or recent
}
