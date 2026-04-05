{
  config,
  pkgs,
  lib,
  ...
}:
{
  # SSH Hardening
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };

  # Modern collaborative brute-force protection
  services.crowdsec = {
    enable = true;
    autoUpdateService = true;
    openFirewall = true;
    hub = {
      collections = [
        "crowdsecurity/linux"
        "crowdsecurity/sshd"
        "crowdsecurity/nginx"
        "crowdsecurity/whitelist-good-actors"
      ];
    };
  };

  # Firewall bouncer for CrowdSec
  services.crowdsec-firewall-bouncer.enable = true;

  # Fail2Ban as a safety net
  services.fail2ban = {
    enable = true;
    maxretry = 6;
    ignoreIP = [
      "127.0.0.1/8"
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];
  };

  # System Auditing (disabled in containers as they lack kernel access)
  security.auditd.enable = lib.mkIf (!config.boot.isContainer) true;
  security.audit = lib.mkIf (!config.boot.isContainer) {
    enable = true;
    rules = [
      "-w /etc/passwd -p wa -k passwd_changes"
      "-w /etc/shadow -p wa -k shadow_changes"
      "-w /etc/sudoers -p wa -k sudoers_changes"
    ];
  };

  # Security analysis tools
  environment.systemPackages = with pkgs; [
    lynis
    clamav
  ];
}
