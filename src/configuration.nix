{ config, lib, pkgs, ... }: {
  imports = [
    #installer-only ./hardware-configuration.nix
    ./ssh-keys.nix
  ];
  boot.loader.grub.devices = ["{{vals.grub_device}}"];

  networking.hostName = "unprovisioned";
  networking.nameservers = ["1.1.1.1"];
{% if vals.serial %}
  boot.kernelParams = [ "console=ttyS0,115200n8" ];
{% endif %}

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "yes";
  };

  users.users.root = {
    # Password is "linux"
    hashedPassword = lib.mkForce "$6$7IKExnDde920x.YH$ggegnnKJYdmg1Wt33fxuPpM.MmIaX32LXVyjL8ed7ohT385lKotFGzRpitncQ3pd9Lci1QCFGRn2tVJGxkFAm0";
  };
}
