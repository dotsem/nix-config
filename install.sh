#!/usr/bin/env bash

# Usage: ./install.sh <hostname> <ip-address>
# Example: ./install.sh nasaPC 192.168.1.50

HOSTNAME=$1
IP=$2

if [ -z "$HOSTNAME" ] || [ -z "$IP" ]; then
  echo "Usage: ./install.sh <hostname> <ip-address>"
  exit 1
fi

echo "Installing NixOS on $HOSTNAME ($IP)..."

# This uses nixos-anywhere to partition and install
# It assumes you have SSH access to the target machine (even if it's a generic ISO)

npx -y nixos-anywhere \
  --flake ".#$HOSTNAME" \
  --extra-files ./common/disko-config.nix \
  "root@$IP"
