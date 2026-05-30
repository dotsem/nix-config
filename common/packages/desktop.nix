{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Web Browsers & Communication
    firefox
    google-chrome
    brave
    vesktop
    networkmanager-openvpn

    # Code Editors & IDEs
    vscode
    antigravity
    zed-editor
    android-studio
    flutter
    postman
    insomnia

    # Productivity & Notes
    libreoffice-still
    obsidian
    qalculate-gtk

    # Media & Audio Creation
    ardour
    audacity
    cava
    easyeffects
    crosspipe
    mpv
    openshot-qt
    pavucontrol
    playerctl
    spotify
    vlc

    # Graphics & 3D
    blender
    feh
    gimp
    imagemagick
    rawtherapee
    kdePackages.gwenview

    # Desktop Utilities & File Managers
    baobab
    bitwarden-desktop
    libnotify
    mousepad
    thunar
    thunar-archive-plugin
    xarchiver
    zenity
    networkmanagerapplet
    udiskie
    gnome-keyring
    seahorse
    libsecret

    # Thumbnailers & Document Support
    tumbler
    ffmpegthumbnailer
    libgsf
    poppler

    # Wayland / Compositor Utilities
    alacritty
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

    # Gaming & Virtualization
    lutris
    prismlauncher
    openttd
    steam
    virt-manager

    # Other Utilities
    simple-scan
    tuxguitar
    blueman
  ];
}
