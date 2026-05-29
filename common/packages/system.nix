{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Modern Terminal Alternatives
    bat
    duf
    eza
    fd
    fzf
    ripgrep
    ripgrep-all
    sd

    # System Monitoring & Info
    glances
    htop
    inxi

    # File & Archive Management
    lf
    p7zip
    rclone
    rsync
    stow
    unzip
    unrar
    upx

    # Networking & Security
    nmap
    whois
    wakeonlan

    # Process & Hardware Diagnostics
    cpulimit
    dmidecode
    smartmontools
    strace
    stress
    v4l-utils

    # Terminal Utilities & Fun
    chafa
    cowsay
    dos2unix
    dosfstools
    parallel
    patch
    plocate
    pv
    ueberzugpp
    xxHash
  ];
}
