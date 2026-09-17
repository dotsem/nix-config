{ config, lib, ... }:
{
  options.custom.server.sopsPassword = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable sops-managed password for user sem";
    };
  };

  config = lib.mkIf config.custom.server.sopsPassword.enable {
    sops.secrets.sem_password = {
      neededForUsers = true;
    };
    users.users.sem.passwordFile = config.sops.secrets.sem_password.path;
  };
}
