#!/bin/sh

nix-channel --add https://nixos.org/channels/nixos-24.05 nixos
nix-channel --update
cd /tmp/
nix-build
mv result/iso/*.iso nixos.iso
rm -rf ./result
chown nobody:nobody nixos.iso
chmod 666 nixos.iso
