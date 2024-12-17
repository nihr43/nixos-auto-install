{
	system ? "x86_64-linux",
}:
(import <nixpkgs/nixos/lib/eval-config.nix> {
	inherit system;
	modules = [
		<nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
		./configuration.nix
		({ config, pkgs, lib, ... }: {
			systemd.services.install = {
				description = "Bootstrap a NixOS installation";
				wantedBy = [ "multi-user.target" ];
				after = [ "network.target" "polkit.service" ];
				path = [ "/run/current-system/sw/" ];
				script = with pkgs; ''
					echo 'journalctl -fu install' >>~nixos/.bash_history
					set -eux
					wipefs -a {{vals.root_device}}
					parted {{vals.root_device}} -- mklabel msdos
					parted {{vals.root_device}} -- mkpart primary 4MB {{vals.root_size}}
					parted {{vals.root_device}} -- set 1 boot on
					mkfs.ext4 -L nixos {{vals.root_partition}}
					sync
					mount /dev/disk/by-label/nixos /mnt
					install -D ${./configuration.nix} /mnt/etc/nixos/configuration.nix
					install -D ${./hardware-configuration.nix} /mnt/etc/nixos/hardware-configuration.nix
                                        install -D ${./ssh-keys.nix} /mnt/etc/nixos/ssh-keys.nix
					sed -i -E 's/(\w*)#installer-only /\1/' /mnt/etc/nixos/*

                                        sleep 10
                                        nix-channel --add https://nixos.org/channels/nixos-24.11 nixos
                                        nix-channel --update
					${config.system.build.nixos-install}/bin/nixos-install \
						--no-root-passwd \
						--cores 0

					${systemd}/bin/shutdown -r now
				'';
				environment = config.nix.envVars // {
					inherit (config.environment.sessionVariables) NIX_PATH;
					HOME = "/root";
				};
				serviceConfig = {
					Type = "oneshot";
				};
			};
		})
	];
}).config.system.build.isoImage
