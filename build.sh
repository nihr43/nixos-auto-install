#!/bin/sh

nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update
cd /tmp/
nix-build
mv result/iso/*.iso nixos.iso
rm -rf ./result
chown nobody:nobody nixos.iso
chmod 666 nixos.iso
