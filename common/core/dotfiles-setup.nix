{ config, pkgs, lib, ... }: {
  systemd.user.services.dotfiles-setup = {
    description = "Create user directory structures and sync dotfiles via GNU Stow";
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    restartIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      ${if config.custom.isDesktop then ''
        mkdir -p $HOME/Downloads $HOME/Documents $HOME/Desktop $HOME/Music $HOME/Pictures $HOME/Videos
        mkdir -p $HOME/prog/{c,c++,csharp,di,flutter,go,web,java,linux-web-services,php,python,rust,shell,sin}
      '' else ''
        mkdir -p $HOME/.config
        # purge stray desktop symlinks and directories previously linked onto servers
        for stray in "$HOME"/*; do
          if [ -L "$stray" ]; then
            link_target=$(readlink "$stray")
            if [[ "$link_target" == *".dotfiles/wallpapers"* || "$link_target" == *".dotfiles/gtk"* ]]; then
              rm -f "$stray"
            fi
          fi
        done
        rmdir $HOME/Desktop $HOME/Music $HOME/Pictures $HOME/Videos 2>/dev/null || true
      ''}

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

      mkdir -p $HOME/.config

      cd "$HOME/.dotfiles"

      # Pre-stow conflict resolution
      while read -r stow_file; do
        rel_path="''${stow_file#./}"
        rel_path="''${rel_path#*/}"
        target="$HOME/$rel_path"

        # prevent deleting files in .dotfiles when target traverses a symlinked parent directory
        real_target=$(realpath -m "$target" 2>/dev/null || true)
        if [[ "$real_target" == "$HOME/.dotfiles"* ]]; then
          continue
        fi

        if [ -e "$target" ] || [ -L "$target" ]; then
          if [ -L "$target" ]; then
            link_target=$(readlink "$target")
            if [[ "$link_target" == *".dotfiles"* ]]; then
              continue
            fi
          fi

          echo "Removing conflicting target: $target"
          rm -rf "$target"
        fi
      done < <(find . -not -path './.git/*' -not -name '.gitignore' -not -type d)

      # Stow packages
      headless_packages=("bash" "fish" "nvim" "btop" "fastfetch" "lf" "tmux" "git")

      for dir in */; do
        dir="''${dir%/}"
        if [[ "$dir" != .* ]]; then
          ${if !config.custom.isDesktop then ''
            is_headless=0
            for pkg in "''${headless_packages[@]}"; do
              if [ "$dir" = "$pkg" ]; then
                is_headless=1
                break
              fi
            done
            if [ "$is_headless" -eq 0 ]; then
              echo "Skipping non-headless package on server: $dir"
              continue
            fi
          '' else ""}

          echo "Stowing package: $dir"
          
          ignore_pattern=""
          while read -r symlink_file; do
            if [ -L "$symlink_file" ]; then
              link_target=$(readlink "$symlink_file")
              if [[ "$link_target" == /* ]]; then
                rel_symlink="''${symlink_file#$dir/}"
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

      ${lib.optionalString config.custom.isDesktop ''
        # Ensure Niri's dms/outputs.kdl exists so the config include doesn't crash Niri.
        mkdir -p $HOME/.config/niri/dms
        rm -f $HOME/.config/niri/dms/outputs.kdl
        echo "Creating Niri VM fallback outputs.kdl..."
        cat <<'EOF' > $HOME/.config/niri/dms/outputs.kdl
debug {
    disable-cursor-plane
}
EOF
      ''}
    '';
  };
}
