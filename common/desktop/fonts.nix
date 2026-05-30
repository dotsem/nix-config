{ config, pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      fira-code
      jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      material-symbols
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrains Mono" "FiraCode Nerd Font" ];
        sansSerif = [ "DejaVu Sans" ];
        serif = [ "DejaVu Serif" ];
      };
    };
  };
}
