{
  description = "Centralized DevShells for Semdot";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells = {
          rust = pkgs.mkShell {
            buildInputs = with pkgs; [ rustc cargo rustfmt rust-analyzer clippy sccache ];
            shellHook = "echo '⚡ Rust DevShell Activated!'";
          };
          go = pkgs.mkShell {
            buildInputs = with pkgs; [ go gopls golangci-lint ];
            shellHook = "echo '⚡ Go DevShell Activated!'";
          };
          python = pkgs.mkShell {
            buildInputs = with pkgs; [
              (python3.withPackages (ps: with ps; [ pip requests numpy pandas ]))
              python3Packages.black
              python3Packages.isort
            ];
            shellHook = "echo '⚡ Python DevShell Activated!'";
          };
          web = pkgs.mkShell {
            buildInputs = with pkgs; [ nodejs pnpm bun npm typescript ];
            shellHook = "echo '⚡ Web (Node/Bun/PNPM) DevShell Activated!'";
          };
          flutter = pkgs.mkShell {
            buildInputs = with pkgs; [ flutter dart ];
            shellHook = "echo '⚡ Flutter/Dart DevShell Activated!'";
          };
          cpp = pkgs.mkShell {
            buildInputs = with pkgs; [ gcc gnumake cmake gdb lldb clang-tools ];
            shellHook = "echo '⚡ C/C++ DevShell Activated!'";
          };
          csharp = pkgs.mkShell {
            buildInputs = with pkgs; [ dotnet-sdk ];
            shellHook = "echo '⚡ C#/.NET DevShell Activated!'";
          };
          java = pkgs.mkShell {
            buildInputs = with pkgs; [ jdk ];
            shellHook = "echo '⚡ Java DevShell Activated!'";
          };
          php = pkgs.mkShell {
            buildInputs = with pkgs; [ php phpPackages.composer laravel ];
            shellHook = "echo '⚡ PHP DevShell Activated!'";
          };
          shell = pkgs.mkShell {
            buildInputs = with pkgs; [ shellcheck shfmt ];
            shellHook = "echo '⚡ Shell Scripting DevShell Activated!'";
          };
        };
      });
}
