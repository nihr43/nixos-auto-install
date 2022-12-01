{
	system ? "x86_64-linux",
}:
(import <nixpkgs/nixos/lib/eval-config.nix> {
	inherit system;
	modules = [
		<nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
		./configuration.nix
		({ config, pkgs, lib, ... }: {
			hardware.enableAllFirmware = false;

			systemd.services.install = {
				description = "Bootstrap a NixOS installation";
				wantedBy = [ "multi-user.target" ];
				after = [ "network.target" "polkit.service" ];
				path = [ "/run/current-system/sw/" ];
				script = with pkgs; ''
					echo 'journalctl -fb -n100 -uinstall' >>~nixos/.bash_history

					set -eux

					wait-for() {
						for _ in seq 10; do
							if $@; then
								break
							fi
							sleep 1
						done
					}

					lsblk >/dev/kmsg

					dev=/dev/sda
					[ -b /dev/nvme0n1 ] && dev=/dev/nvme0n1
					[ -b /dev/vda ] && dev=/dev/vda

					shred -v $dev
					sync

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
