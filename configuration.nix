{ config, lib, pkgs, ... }: {
	imports = [
		<nixpkgs/nixos/modules/profiles/all-hardware.nix>
		<nixpkgs/nixos/modules/profiles/base.nix>
		#installer-only ./hardware-configuration.nix
		./ssh-keys.nix
	];
        boot.loader.grub.devices = ["/dev/sda"];
	nixpkgs.config.allowUnfree = true;
	security.sudo.wheelNeedsPassword = false;

	networking.hostName = "unprovisioned";
	networking.nameservers = ["1.1.1.1"];

	services.openssh = {
		enable = true;
		settings.PasswordAuthentication = false;
		settings.KbdInteractiveAuthentication = false;
		settings.PermitRootLogin = "yes";
	};

	users.mutableUsers = false;
	users.users.root = {
		# Password is "linux"
		hashedPassword = lib.mkForce "$6$7IKExnDde920x.YH$ggegnnKJYdmg1Wt33fxuPpM.MmIaX32LXVyjL8ed7ohT385lKotFGzRpitncQ3pd9Lci1QCFGRn2tVJGxkFAm0";
	};

	environment.systemPackages = with pkgs; [
		python3
	];
}
