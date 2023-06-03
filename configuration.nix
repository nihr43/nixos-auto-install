{ config, lib, pkgs, ... }: {
	imports = [
		<nixpkgs/nixos/modules/profiles/all-hardware.nix>
		<nixpkgs/nixos/modules/profiles/base.nix>
		#installer-only ./hardware-configuration.nix
	];

	nixpkgs.config.allowUnfree = true;

	zramSwap.enable = true;
	services.logind.lidSwitch = "ignore";

	security.sudo.wheelNeedsPassword = false;

	networking.hostName = "install";

	services.openssh.enable = true;
	services.openssh.settings.PermitRootLogin = "yes";

	users.mutableUsers = false;
	users.users.root = {
		# Password is "linux"
		hashedPassword = lib.mkForce "$6$7IKExnDde920x.YH$ggegnnKJYdmg1Wt33fxuPpM.MmIaX32LXVyjL8ed7ohT385lKotFGzRpitncQ3pd9Lci1QCFGRn2tVJGxkFAm0";
	};

	services.avahi = {
		enable = true;
		ipv4 = true;
		ipv6 = true;
		nssmdns = true;
		publish = { enable = true; domain = true; addresses = true; };
	};

	environment.systemPackages = with pkgs; [
		coreutils
		curl
		file
		git
		htop
		lsof
		nano
		openssl
		pciutils
		pv
		tmux
		tree
		unar
		vim_configurable
		wget
		zip
	];
}
