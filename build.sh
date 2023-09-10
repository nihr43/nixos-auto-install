#!/bin/sh

nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update
cd /root/
nix-build
mv result/iso/*.iso nixos.iso
rm -rf ./result
