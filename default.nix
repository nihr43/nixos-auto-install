(import <nixpkgs/nixos/lib/eval-config.nix> {
	system = "x86_64-linux";
	modules = [
		<nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
		./configuration.nix
		({ config, pkgs, lib, ... }: {
			hardware.enableAllFirmware = true;

			systemd.services.install = {
				description = "Bootstrap a NixOS installation";
				wantedBy = [ "multi-user.target" ];
				after = [ "network.target" "polkit.service" ];
				path = [ "/run/current-system/sw/" ];
				script = with pkgs; ''
					echo 'journalctl -fb -n100 -uinstall' >>~nixos/.bash_history

					set -eux

					dev=/dev/sda
					[ -b /dev/vda ] && dev=/dev/vda

					${utillinux}/bin/sfdisk --wipe=always $dev <<-END
						label: gpt

						name=BOOT, size=512MiB, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
						name=NIXOS
					END
					mkfs.fat -F 32 -n boot ''${dev}1

					${cryptsetup}/bin/cryptsetup luksFormat --type=luks2 --label=root ''${dev}2 /dev/zero --keyfile-size=1
					${cryptsetup}/bin/cryptsetup luksOpen ''${dev}2 root --key-file=/dev/zero --keyfile-size=1
					mkfs.ext4 -L nixos /dev/mapper/root

					sync
					sleep 10 # Allow /dev/dis/by-label names to appear.

					mount /dev/mapper/root /mnt

					mkdir /mnt/boot
					mount /dev/disk/by-label/boot /mnt/boot

					install -D ${./configuration.nix} /mnt/etc/nixos/configuration.nix
					install -D ${./hardware-configuration.nix} /mnt/etc/nixos/hardware-configuration.nix

					sed -i -E 's/(\w*)#installer-only /\1/' /mnt/etc/nixos/*

					${config.system.build.nixos-install}/bin/nixos-install \
						--system ${(import <nixpkgs/nixos/lib/eval-config.nix> {
							system = "x86_64-linux";
							modules = [
								./configuration.nix
								./hardware-configuration.nix
							];
						}).config.system.build.toplevel} \
						--no-root-passwd \
						--cores 0

					echo 'Shutting off in 1min'
					${systemd}/bin/shutdown +1
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
