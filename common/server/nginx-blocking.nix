{
  # block private files and directories
  "~ /\\.(?!well-known(/|$))" = {
    return = "404";
  };

  # block sensitive extensions and compressed backups
  "~* \\.(env|key|pem|pypirc|bak|config|sql|yaml|yml|db|sqlite|log|sh|swp)(\\.(gz|zip|tar|tgz|7z|rar|bz2))?(/|$)" = {
    return = "404";
  };

  # block unextended private ssh keys
  "~* /(id_rsa|id_dsa|id_ecdsa|id_ed25519)(/|$)" = {
    return = "404";
  };
}
