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
    ./homepage.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "lobby";

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."lobby.home" = {
      default = true;
      serverAliases = [
        hosts.lobby.ip
        "_"
      ];
      locations."/assets/" = {
        alias = "${./assets}/";
        extraConfig = ''
          expires 30d;
          add_header Cache-Control "public, max-age=2592000, immutable";
        '';
      };
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
