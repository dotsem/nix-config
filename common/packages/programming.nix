{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # devops & cloud
    k9s
    kubectl
    helm
    kind
    ansible
    docker-compose
    openvpn

    # utilities
    jq
    yq
    gh
    tldr
    nixfmt
    golangci-lint
    just
    lefthook
    neovim
    sqlite
    sqlc
    uv
    copier
    meld
    zap

    # build toolchains
    gcc
    gnumake
    cmake
    ninja
    ccache

    # languages & runtimes
    go
    govulncheck
    go-task
    rustc
    cargo
    bun
    pnpm
    php
    php.packages.composer
    dotnet-sdk
    jdk21
    mise
    claude-code
    azure-functions-core-tools
  ];
}
