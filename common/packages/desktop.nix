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
    helvum
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
    bitwarden
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

    # Thumbnailers & Document Support (font.sh/setup.sh equivalents)
    tumbler
    ffmpegthumbnailer
    libgsf
    poppler

    # Wayland / Compositor Utilities
    alacritty
    brightnessctl
    dunst
    fuzzel
    grim
    hypridle
    hyprlock
    hyprpaper
    hyprpicker
    hyprshot
    hyprsunset
    mako
    mangohud
    matugen
    nwg-look
    slurp
    wl-clipboard
    wl-mirror
    wl-screenrec
    wofi
    wtype
    waybar
    gtk-layer-shell
    polybar

    # Gaming & Virtualization
    lutris
    minecraft-launcher
    openttd
    steam
    virt-manager

    # Other Utilities
    simple-scan
    tuxguitar
    xsel
    blueman
    os-prober
  ];
}
