{ config, pkgs, lib, ... }: {
  boot.loader.refind = {
    enable = true;

    # Limit entries to avoid horizontal clutter from old generations
    maxGenerations = 3;

    extraConfig = ''
      # Query and set max GOP resolution to prevent text-mode fallback on laptops
      resolution max
      use_graphics_for linux

      # Wallpaper
      banner background.png
      banner_scale fillscreen

      # UI decluttering: hide broken text tools like about and hidden tags
      showtools reboot, shutdown, firmware
      hideui hints,singleuser,safemode
      small_icon_size 48
      big_icon_size 128
      timeout 5
    '';

    # rEFInd drops to text mode if the icons directory is missing.
    # NixOS's installer does not copy icons by default, so we provide them here.
    additionalFiles = {
      "background.png" = ./assets/refind-bg.png;
    } // (
      lib.mapAttrs'
        (name: _: lib.nameValuePair "icons/${name}" "${pkgs.refind}/share/refind/icons/${name}")
        (builtins.readDir "${pkgs.refind}/share/refind/icons")
    );
  };

  # Upstream nixpkgs hardcodes `default_selection 2` in refind-install.py, which causes
  # rEFInd to default to the previous generation instead of the latest (generation 1).
  system.build.installBootLoader = lib.mkForce (pkgs.replaceVarsWith {
    src = pkgs.runCommand "refind-install.py" {} ''
      sed 's/default_selection {.*}/default_selection 1/' \
        ${pkgs.path}/nixos/modules/system/boot/loader/refind/refind-install.py > $out
    '';
    isExecutable = true;
    replacements = {
      python3 = pkgs.python3.withPackages (python-packages: [ python-packages.psutil ]);
      configPath = pkgs.writeText "refind-install.json" (
        builtins.toJSON {
          nixPath = config.nix.package;
          efiBootMgrPath = pkgs.efibootmgr;
          refindPath = config.boot.loader.refind.package;
          efiMountPoint = config.boot.loader.efi.efiSysMountPoint;
          fileSystems = config.fileSystems;
          luksDevices = config.boot.initrd.luks.devices;
          canTouchEfiVariables = config.boot.loader.efi.canTouchEfiVariables;
          efiRemovable = config.boot.loader.refind.efiInstallAsRemovable;
          maxGenerations = if config.boot.loader.refind.maxGenerations == null then 0 else config.boot.loader.refind.maxGenerations;
          hostArchitecture = pkgs.stdenv.hostPlatform.parsed.cpu;
          timeout = if config.boot.loader.timeout != null then config.boot.loader.timeout else 10;
          extraConfig = config.boot.loader.refind.extraConfig;
          additionalFiles = config.boot.loader.refind.additionalFiles;
        }
      );
    };
  });
}

