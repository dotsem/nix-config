{ pkgs, lib, ... }: {
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
}
