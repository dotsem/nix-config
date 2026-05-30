{ config, pkgs, ... }: {
  programs.git = {
    enable = true;
    config = {
      user.name = config.custom.gitName;
      user.email = config.custom.gitEmail;
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };
}
