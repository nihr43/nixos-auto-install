# nixos-auto-install

Builds a batch of self-installing [NixOS](https://nixos.org/) isos using values from `config.yaml`.

See `ssh-keys.nix` for landing a root ssh key.

## usage

Edit `config.yaml` and run `just` on nixos.

`root_size` is expected to be some value that `parted` will understand (GB, %).

See also `just test` to build and run in qemu.

A `journalctl` command is injected into the bash history of the installer, so to watch progress just 'up arrow' and 'enter'.

---

Forked from [kevincox/nixos-auto-install](https://gitlab.com/kevincox/nixos-auto-install).
