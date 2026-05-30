{ config, pkgs, ... }: {
  systemd.user.services.dotfiles-setup = {
    description = "Create user directory structures and sync dotfiles via GNU Stow";
    wantedBy = [ "default.target" ];
    # Git clone requires the network to be fully up
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p $HOME/Downloads $HOME/Documents $HOME/Desktop $HOME/Music $HOME/Pictures $HOME/Videos

      mkdir -p $HOME/prog/{c,c++,csharp,di,flutter,go,web,java,linux-web-services,php,python,rust,shell,sin}

      if [ ! -d "$HOME/.dotfiles" ]; then
        ${pkgs.git}/bin/git clone "${config.custom.dotfilesUrl}" "$HOME/.dotfiles"
      fi

      # Prevent stow from creating a directory-level symlink over .config
      mkdir -p $HOME/.config

      cd "$HOME/.dotfiles"
      ${pkgs.stow}/bin/stow -v -R --no-folding -t "$HOME" .
    '';
  };
}
