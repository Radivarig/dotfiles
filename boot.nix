{ pkgs, ... }:
let
machine = import ./machine-settings.nix {inherit pkgs;};
in
if machine.model == "xps15"
then {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/nvme0n1p6";
      preLVM = true;
    };
  };
}
else if machine.model == "xps13"
then {
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/sda3";
      preLVM = true;
    };
  };
}
else throw
