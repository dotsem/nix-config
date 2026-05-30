{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ sops age ssh-to-age ];

  # Derive the age decryption key from the machine's SSH host key at activation time.
  # Run `ssh-keyscan <host> | ssh-to-age` to get the public age key for .sops.yaml.
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
