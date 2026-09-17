{ config, lib, ... }:
{
  options.custom.server.sopsPassword = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "enable sops-managed password for user sem";
    };
  };

  config = lib.mkIf config.custom.server.sopsPassword.enable {
    users.mutableUsers = false;

    sops.secrets.sem_password = {
      neededForUsers = true;
    };
    users.users.sem.hashedPasswordFile = config.sops.secrets.sem_password.path;
  };
}
