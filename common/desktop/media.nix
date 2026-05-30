{ config, pkgs, ... }: {
  # Pipewire for audio and video
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    # Stutter prevention & low-latency tuning under heavy CPU/GPU loads
    extraConfig.pipewire = {
      "99-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 128;
          "default.clock.max-quantum" = 2048;
        };
      };
    };

    # Match buffer tuning for PulseAudio applications/games
    extraConfig.pipewire-pulse = {
      "99-low-latency" = {
        "pulse.properties" = {
          "pulse.min.req" = "128/48000";
          "pulse.default.req" = "1024/48000";
          "pulse.max.req" = "2048/48000";
          "pulse.min.quantum" = "128/48000";
        };
      };
    };
  };

  # Real-time support
  security.rtkit.enable = true;

  # Printing support (complete out-of-the-box USB and network printing)
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint      # High-quality drivers for Canon, Epson, Lexmark, Sony, etc.
      gutenprintBin   # Binary version for extra proprietary capabilities
      hplip           # HP device support
    ];
  };

  # Driverless IPP-over-USB printing and scanning support
  services.ipp-usb.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Scanning support
  hardware.sane.enable = true;
  
  # Bluetooth
  hardware.bluetooth.enable = true;
}
