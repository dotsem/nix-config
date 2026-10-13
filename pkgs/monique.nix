{ lib
, python3Packages
, fetchFromGitHub
, gtk4
, libadwaita
, gobject-introspection
, wrapGAppsHook4
}:

python3Packages.buildPythonApplication rec {
  pname = "monique";
  version = "0.8.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "ToRvaLDz";
    repo = "monique";
    rev = "v${version}";
    hash = "sha256-ip0oha6Tp9rbxAPdTZDPxuyd5nqUMl2M+oQ9T9T2V50=";
  };

  nativeBuildInputs = [
    python3Packages.setuptools
    wrapGAppsHook4
    gobject-introspection
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    pyudev
  ];

  postInstall = ''
    install -Dm644 data/com.github.monique.desktop \
      $out/share/applications/com.github.monique.desktop
    install -Dm644 data/com.github.monique.svg \
      $out/share/icons/hicolor/scalable/apps/com.github.monique.svg
    install -Dm644 data/moniqued.service \
      $out/lib/systemd/user/moniqued.service
  '';

  doCheck = false;

  meta = with lib; {
    description = "MONitor Integrated QUick Editor for Hyprland, Sway and Niri";
    homepage = "https://github.com/ToRvaLDz/monique";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "monique";
  };
}
