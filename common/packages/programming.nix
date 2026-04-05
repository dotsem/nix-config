{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Rust
    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy

    # Go
    go
    gopls

    # Python
    (python3.withPackages (ps: with ps; [ pip requests numpy pandas ]))
    python3Packages.black
    python3Packages.isort

    # JS/Web
    nodejs
    pnpm
    bun
    npm
    typescript

    # C/C++
    gcc
    gnumake
    cmake
    gdb
    lldb
    clang-tools

    # .NET
    dotnet-sdk

    # Other Essentials
    jq
    yq
    gh
    tldr
  ];

  # Extra configuration if needed for specific languages
}
