{ config, pkgs, lib, ... }: {
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowPing = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      MaxAuthTries = 5;
    };
  };

  services.fail2ban = lib.mkIf (!config.boot.isContainer) {
    enable = true;
    jails.sshd.settings = {
      backend = "systemd";
      filter = "sshd";
      bantime = "24h";
      findtime = "10m";
      maxretry = 5;
    };
  };
}
