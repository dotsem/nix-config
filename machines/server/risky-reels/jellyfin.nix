{ pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;

    # Purge transcode chunks immediately after playback to prevent ssd bloat
    transcoding.deleteSegments = true;

    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };
  };

  # Graphics driver support for hardware transcoding (Intel & AMD VA-API)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # Shared group for local access across human user, jellyfin, and future downloaders
  users.groups.media = { };

  users.users.jellyfin.extraGroups = [
    "video"
    "render"
    "media"
  ];

  users.users.sem.extraGroups = [ "media" ];

  # Declarative directory creation on local storage
  systemd.tmpfiles.rules = [
    "d /media 0775 jellyfin media -"
    "d /media/movies 0775 jellyfin media -"
    "d /media/shows 0775 jellyfin media -"
  ];

  environment.systemPackages = with pkgs; [
    libva-utils # provides vainfo for hardware acceleration diagnostics
  ];
}
