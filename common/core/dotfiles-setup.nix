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
      set -euo pipefail

      mkdir -p $HOME/Downloads $HOME/Documents $HOME/Desktop $HOME/Music $HOME/Pictures $HOME/Videos
      mkdir -p $HOME/prog/{c,c++,csharp,di,flutter,go,web,java,linux-web-services,php,python,rust,shell,sin}

      # wait for internet connection/dns to resolve github before cloning
      echo "checking network availability..."
      for i in {1..12}; do
        if ${pkgs.getent}/bin/getent ahosts github.com >/dev/null 2>&1; then
          echo "network is online!"
          break
        fi
        echo "waiting for network/dns (attempt $i/12)..."
        sleep 5
      done

      if [ ! -d "$HOME/.dotfiles" ]; then
        echo "cloning dotfiles repository..."
        ${pkgs.git}/bin/git clone "${config.custom.dotfilesUrl}" "$HOME/.dotfiles"
      fi

      # Prevent stow from creating a directory-level symlink over .config
      mkdir -p $HOME/.config

      cd "$HOME/.dotfiles"

      # Pre-stow conflict resolution: delete any files, foreign symlinks, or broken symlinks
      # in $HOME that would conflict with our dotfiles stowing.
      while read -r stow_file; do
        rel_path="''${stow_file#./}"
        # Strip the package directory name (e.g., "fish/.config/fish" -> ".config/fish")
        rel_path="''${rel_path#*/}"
        target="$HOME/$rel_path"
        
        if [ -e "$target" ] || [ -L "$target" ]; then
          # If it is a symlink, check if it already points to our dotfiles
          if [ -L "$target" ]; then
            link_target=$(readlink "$target")
            if [[ "$link_target" == *".dotfiles"* ]]; then
              # Already stowed correctly, skip
              continue
            fi
          fi
          
          echo "Removing conflicting target: $target"
          rm -rf "$target"
        fi
      done < <(find . -not -path './.git/*' -not -name '.gitignore' -not -type d)

      # Stow each directory as an individual package
      for dir in */; do
        dir="''${dir%/}"
        if [[ "$dir" != .* ]]; then
          echo "Stowing package: $dir"
          
          # Find all absolute symlinks inside this package and build an ignore pattern
          ignore_pattern=""
          while read -r symlink_file; do
            if [ -L "$symlink_file" ]; then
              link_target=$(readlink "$symlink_file")
              if [[ "$link_target" == /* ]]; then
                # It's an absolute symlink! Get relative path from package root
                rel_symlink="''${symlink_file#$dir/}"
                # Escape dots for regex
                rel_symlink_escaped=$(echo "$rel_symlink" | sed 's/\./\\./g')
                if [ -z "$ignore_pattern" ]; then
                  ignore_pattern="$rel_symlink_escaped"
                else
                  ignore_pattern="$ignore_pattern|$rel_symlink_escaped"
                fi
              fi
            fi
          done < <(find "$dir" -type l 2>/dev/null || true)
          
          if [ -n "$ignore_pattern" ]; then
            echo "Ignoring absolute symlinks in $dir: $ignore_pattern"
            ${pkgs.stow}/bin/stow -v -R --no-folding --ignore="($ignore_pattern)" -t "$HOME" "$dir"
          else
            ${pkgs.stow}/bin/stow -v -R --no-folding -t "$HOME" "$dir"
          fi
        fi
      done

      # Ensure Niri's dms/outputs.kdl exists so the config include doesn't crash Niri.
      # Also inject the software cursor fix for virtualized environments (like Proxmox VMs).
      mkdir -p $HOME/.config/niri/dms
      rm -f $HOME/.config/niri/dms/outputs.kdl
      echo "Creating Niri VM fallback outputs.kdl..."
      cat <<'EOF' > $HOME/.config/niri/dms/outputs.kdl
debug {
    disable-cursor-plane
}
EOF
    '';
  };
}
