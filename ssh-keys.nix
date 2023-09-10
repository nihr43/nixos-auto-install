{ config, ... }: {
	users.users.root.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKL+1xp+nQIbu02D1NmU+4RTPGblUML21TSzF/Pxg5GM"
	];
}
