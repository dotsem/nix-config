{ ... }: {
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

      # UI decluttering
      hideui hints,singleuser,safemode
      small_icon_size 48
      big_icon_size 128
      timeout 5
    '';

    additionalFiles = {
      "background.png" = ./assets/refind-bg.png;
    };
  };
}
