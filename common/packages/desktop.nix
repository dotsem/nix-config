{ config, pkgs, lib, ... }: {
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

      # thumbnailers & document support
      tumbler
      ffmpegthumbnailer
      libgsf
      poppler

      # wayland / compositor utilities
      brightnessctl
      fuzzel
      grim
      hyprlock   # standalone locker, works on niri
      hyprpicker # color picker, wayland-native
      mangohud
      matugen
      mako
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
      # non-essential / heavy applications
      # secondary browsers & chat
      firefox
      google-chrome
      vesktop

      # code editors & developer ides
      android-studio
      flutter
      postman
      insomnia

      # productivity & office
      libreoffice-still
      obsidian
      qalculate-gtk

      # media & audio creation
      ardour
      audacity
      cava
      easyeffects
      crosspipe
      mpv
      vlc

      # graphics & 3d tools
      blender
      feh
      gimp
      imagemagick
      rawtherapee
      kdePackages.gwenview

      # gaming & emulation
      lutris
      prismlauncher
      openttd
      steam

      # virtualization management
      virt-manager

      # other tools
      simple-scan
      tuxguitar
    ]);
  };
}
