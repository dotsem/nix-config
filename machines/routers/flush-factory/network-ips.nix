let
  subnet = "192.168.11.0/24";

  # extract the ip prefix (e.g. "192.168.11.") and mask length (e.g. 24)
  match = builtins.match "([0-9]+\\.[0-9]+\\.[0-9]+\\.)[0-9]+/([0-9]+)" subnet;
  prefix = builtins.elemAt match 0;
  prefixLength = builtins.fromJSON (builtins.elemAt match 1);
in
{
  inherit subnet prefixLength prefix;
  gateway = "${prefix}1";

  # static ip assignments for internal devices
  devices = {
    flush-factory = "${prefix}1";
    battlebus = "${prefix}69";
    rebootvan = "${prefix}70";
  };
}
