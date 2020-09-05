{ config, pkgs, ... }: {
	imports = [
		#installer-only ./hardware-configuration.nix
	];

	nixpkgs.config.allowUnfree = true;

	zramSwap.enable = true;
	services.logind.lidSwitch = "ignore";

	security.sudo.wheelNeedsPassword = false;

	networking.hostName = "install";

	services.openssh.enable = true;
	services.openssh.permitRootLogin = "yes";

	users.mutableUsers = false;
	users.users.root = {
		# Password is "linux"
		hashedPassword = "$6$7IKExnDde920x.YH$ggegnnKJYdmg1Wt33fxuPpM.MmIaX32LXVyjL8ed7ohT385lKotFGzRpitncQ3pd9Lci1QCFGRn2tVJGxkFAm0";
	};

	services.avahi = {
		enable = true;
		ipv4 = true;
		ipv6 = true;
		nssmdns = true;
		publish = { enable = true; domain = true; addresses = true; };
	};

	environment.systemPackages = with pkgs; [
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
