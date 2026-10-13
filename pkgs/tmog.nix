{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, qt6
, systemd
}:

stdenv.mkDerivation rec {
  pname = "tmog";
  version = "1.0.0";

  src = fetchurl {
    url = "https://tmog.org/rtm/downloads/TaskManagerOG-${version}-linux-x86_64.tar.gz";
    hash = "sha256-oUfGE9Sm9cDsFur1KWVZPeUj+fAjHgnCQUYMxjNS8yU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    systemd
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/tmog-task-manager $out/bin/tmog-task-manager
    ln -s $out/bin/tmog-task-manager $out/bin/tmog

    install -Dm644 share/applications/com.tmog.taskmanager.desktop \
      $out/share/applications/com.tmog.taskmanager.desktop
    install -Dm644 share/metainfo/com.tmog.taskmanager.metainfo.xml \
      $out/share/metainfo/com.tmog.taskmanager.metainfo.xml

    for size in 32x32 48x48 64x64 128x128 256x256 512x512; do
      if [ -f share/icons/hicolor/$size/apps/tmog-task-manager.png ]; then
        install -Dm644 share/icons/hicolor/$size/apps/tmog-task-manager.png \
          $out/share/icons/hicolor/$size/apps/tmog-task-manager.png
      fi
    done

    install -Dm644 share/pixmaps/tmog-task-manager.png \
      $out/share/pixmaps/tmog-task-manager.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "Task Manager OG by Dave Plummer";
    homepage = "https://tmog.org";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "tmog";
  };
}
