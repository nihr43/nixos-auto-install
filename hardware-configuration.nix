{ config, pkgs, ... }: {
	hardware.enableAllFirmware = true;

	boot.loader.systemd-boot.enable = true;

	boot.initrd.kernelModules = [
		"kvm-intel"
		"virtio_balloon"
		"virtio_console"
		"virtio_rng"
	];

	boot.initrd.availableKernelModules = [
		"9p"
		"9pnet_virtio"
		"ata_piix"
		"nvme"
		"sr_mod"
		"uhci_hcd"
		"virtio_blk"
		"virtio_mmio"
		"virtio_net"
		"virtio_pci"
		"virtio_scsi"
		"xhci_pci"
	];

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
