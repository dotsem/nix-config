{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # shell & terminal
    starship
    zoxide
    fnm
    atuin
    sccache
    xsel
    xclip
    kitty

    # wayland utilities
    wev
    ydotool
    gpu-screen-recorder
    hyprsunset
    hyprpaper
    hyprshot

    # terminal alternatives
    bat
    duf
    eza
    fd
    fzf
    ripgrep
    ripgrep-all
    sd

    # system monitoring & diagnostics
    glances
    htop
    inxi
    smartmontools
    strace
    stress
    hwinfo
    cpulimit
    dmidecode
    sshs
    usbutils
    tuptime

    # file & archive
    lf
    p7zip
    rclone
    rsync
    stow
    unzip
    unrar
    upx

    # networking & security
    nmap
    whois
    wakeonlan

    # firmware flashing
    heimdall

    # terminal utilities & tools
    chafa
    cowsay
    dos2unix
    dosfstools
    parallel
    patch
    plocate
    pv
    ueberzugpp
    v4l-utils
    xxHash
    rustdesk-flutter
  ];
}
