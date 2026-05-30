{ config, pkgs, ... }: {
  systemd.user.services.dotfiles-setup = {
    description = "Create user directory structures and sync dotfiles via GNU Stow";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Ensure standard XDG directories exist
      mkdir -p $HOME/Downloads $HOME/Documents $HOME/Desktop $HOME/Music $HOME/Pictures $HOME/Videos

      # Create custom programming workspaces
      mkdir -p $HOME/prog/{c,c++,csharp,di,flutter,go,web,java,linux-web-services,php,python,rust,shell,sin}

      # Clone dotfiles repo if not present
      if [ ! -d "$HOME/.dotfiles" ]; then
        ${pkgs.git}/bin/git clone "${config.custom.dotfilesUrl}" "$HOME/.dotfiles"
      fi

      # Ensure Stow doesn't create directory-level symlinks for .config
      mkdir -p $HOME/.config

      # Stow configuration files
      cd "$HOME/.dotfiles"
      ${pkgs.stow}/bin/stow -v -R -t "$HOME" .
    '';
  };
}
