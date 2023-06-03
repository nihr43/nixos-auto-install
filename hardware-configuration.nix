{ config, pkgs, ... }: {
	boot.loader.systemd-boot.enable = true;

	fileSystems."/boot" = {
		device = "/dev/disk/by-label/boot";
		fsType = "vfat";
	};

	boot.initrd.luks.devices.root = {
		device = "/dev/disk/by-label/root";

		# WARNING: Leaks some metadata, see cryptsetup man page for --allow-discards.
		allowDiscards = true;

		# Set your own key with:
		# cryptsetup luksChangeKey /dev/disk/by-label/root --key-file=/dev/zero --keyfile-size=1
		# You can then delete the rest of this block.
		keyFile = "/dev/zero";
		keyFileSize = 1;

		fallbackToPassword = true;
	};

	fileSystems."/" = {
		device = "/dev/mapper/root";
		fsType = "ext4";
	};
}
