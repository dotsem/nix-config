{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Global Developer Utilities (No compile runtimes)
    jq
    yq
    gh
    tldr
  ];
}
