{
  config,
  pkgs,
  lib,
  hosts,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ../../../common/core/default.nix
    ../../../common/server/default.nix
    ./homebox.nix
    ./kitchenowl.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "greasy-grove";

  networking.useDHCP = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = hosts.greasy-grove.ip;
      prefixLength = hosts.greasy-grove.prefixLength;
    }
  ];
  networking.defaultGateway = {
    address = hosts.greasy-grove.gateway;
    interface = "eth0";
  };
  networking.nameservers = [
    hosts.adguard-home.ip
    "1.1.1.1"
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.kitchenowl_jwt_secret = {
    restartUnits = [ "kitchenowl.service" ];
  };
  sops.templates."kitchenowl-env".content = ''
    JWT_SECRET_KEY=${config.sops.placeholder.kitchenowl_jwt_secret}
  '';

  environment.systemPackages = with pkgs; [
    curl
    vim
    tmux
    docker-compose
  ];

  networking.firewall.allowedTCPPorts = [
    22
    7745
    8080
  ];
}
