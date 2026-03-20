{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../common/core/default.nix
    ../../../common/server/boot.nix
  ];

  networking.hostName = "server";

  # Server usually doesn't need a UI
  # Just ssh and generic services
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  # Minimal packages
  environment.systemPackages = with pkgs; [
    tmux
    vim
    rsync
  ];

  # Basic firewall for server
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
}
