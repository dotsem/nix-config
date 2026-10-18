{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ./profile-state.nix
  ];

  options.custom.desktop.fullProfile.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "whether to install heavy GUI, development, media creation, and gaming applications. set to false for rapid bootstrap / minimal installs.";
  };

  config = {
    environment.systemPackages = with pkgs; [
      # essential desktop base
      # web browsers & core networking
      brave
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      networkmanager-openvpn

      # terminal & editor
      alacritty
      mousepad
      vscode
      antigravity
      zed-editor

      # desktop utilities & file managers
      baobab
      bitwarden-desktop
      libnotify
      thunar
      thunar-archive-plugin
      xarchiver
      zenity
      networkmanagerapplet
      udiskie
      gnome-keyring
      seahorse
      libsecret
      spotify
      steam-run

      # thumbnailers & document support
      tumbler
      ffmpegthumbnailer
      libgsf
      poppler

      # wayland / compositor utilities
      brightnessctl
      fuzzel
      grim
      hyprlock
      hyprpicker
      mangohud
      matugen
      monique
      nwg-look
      slurp
      wl-clipboard
      wl-mirror
      wl-screenrec
      wtype

      # base utilities
      pavucontrol
      playerctl
      blueman
    ] ++ (lib.optionals config.custom.desktop.fullProfile.enable [
      # heavy / secondary applications
      firefox
      google-chrome
      vesktop

      # editors & ides
      android-studio
      flutter
      postman
      insomnia
      jetbrains-toolbox

      # productivity & office
      libreoffice-still
      obsidian
      qalculate-gtk
      staruml

      # media & audio creation
      ardour
      audacity
      cava
      easyeffects
      crosspipe
      guitarix
      celluloid
      vlc
      obs-studio
      openshot-qt

      # graphics & 3d tools
      blender
      feh
      gimp
      imagemagick
      rawtherapee
      loupe

      # gaming & emulation
      lutris
      prismlauncher
      openttd
      steam

      # remote access & diagnostics
      remmina
      moonlight-qt
      tmog
      bitwarden-cli

      # flashing & hardware utilities
      rpi-imager

      # virtualization management
      virt-manager

      # other tools
      simple-scan
      tuxguitar
    ]);
  };
}
