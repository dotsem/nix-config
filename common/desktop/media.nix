{ config, pkgs, ... }: {
  # Pipewire for audio and video
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Real-time support
  security.rtkit.enable = true;

  # Printing support
  services.printing.enable = true;
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
