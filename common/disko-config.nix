{ config, lib, ... }: {
  options.custom.disko.swap = {
    enable = lib.mkEnableOption "dedicated swap partition with hibernation support";
    size = lib.mkOption {
      type = lib.types.str;
      default = "36G";
      description = "Size of the swap partition";
    };
  };

  config = {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = lib.mkDefault "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                priority = 1;
                name = "ESP";
                start = "1M";
                end = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
            } // lib.optionalAttrs config.custom.disko.swap.enable {
              swap = {
                priority = 2;
                name = "swap";
                size = config.custom.disko.swap.size;
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
              };
            } // {
              root = {
                priority = 3;
                name = "root";
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
