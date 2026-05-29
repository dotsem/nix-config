{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # DevOps/Cloud Tools
    k9s
    kubectl

    # Developer Utilities
    jq
    yq
    gh
    tldr
    nixfmt
    golangci-lint
    just
    neovim
    sqlite
  ];
}
