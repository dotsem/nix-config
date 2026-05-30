{ config, lib, ... }: {
  options.custom = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "sem";
      description = "Default system username";
    };
    gitName = lib.mkOption {
      type = lib.types.str;
      default = "Sem Van Broekhoven";
      description = "Global Git name for commits";
    };
    gitEmail = lib.mkOption {
      type = lib.types.str;
      default = "sem.van.broekhoven@gmail.com";
      description = "Global Git email address";
    };
    dotfilesUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://github.com/dotsem/dotfiles.git";
      description = "URL of the user dotfiles git repository";
    };
  };
}
