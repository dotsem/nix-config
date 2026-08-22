{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.homebox = {
    enable = true;
    settings = {
      HBOX_MODE = "production";
      HBOX_STORAGE_CONN_STRING = "file:///var/lib/homebox";
      HBOX_STORAGE_PREFIX_PATH = "data";
      HBOX_DATABASE_DRIVER = "sqlite3";
      HBOX_DATABASE_SQLITE_PATH = "/var/lib/homebox/data/homebox.db?_pragma=busy_timeout=999&_pragma=journal_mode=WAL&_fk=1";
      HBOX_OPTIONS_ALLOW_REGISTRATION = "true";
      HBOX_OPTIONS_GITHUB_RELEASE_CHECK = "false";
      HBOX_WEB_PORT = "7745";
    };
  };
}
