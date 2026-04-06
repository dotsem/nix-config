{
  config,
  lib,
  ...
}:
{
  boot.loader.systemd-boot.enable = lib.mkIf (!config.boot.isContainer) true;
}
