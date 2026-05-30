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
  ];

  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "be-latin1";

  # SSD Trimming 
  services.fstrim.enable = true;

  # Systemd Journal log size limiting
  services.journald.extraConfig = "SystemMaxUse=100M";

  # Nix garbage collection & store optimization
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  system.stateVersion = "25.11"; # Updated to current stable or recent
}
