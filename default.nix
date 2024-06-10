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
					echo 'journalctl -fb -n100 -uinstall' >>~nixos/.bash_history
					set -eux
					wipefs -a /dev/sda
					parted /dev/sda -- mklabel msdos
					parted /dev/sda -- mkpart primary 4MB 100%
					parted /dev/sda -- set 1 boot on
					mkfs.ext4 -L nixos /dev/sda1
					sync
					mount /dev/disk/by-label/nixos /mnt
					install -D ${./configuration.nix} /mnt/etc/nixos/configuration.nix
					install -D ${./hardware-configuration.nix} /mnt/etc/nixos/hardware-configuration.nix
                                        install -D ${./ssh-keys.nix} /mnt/etc/nixos/ssh-keys.nix
					sed -i -E 's/(\w*)#installer-only /\1/' /mnt/etc/nixos/*

                                        sleep 10
                                        nix-channel --add https://nixos.org/channels/nixos-24.05 nixos
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
