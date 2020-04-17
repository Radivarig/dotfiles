{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./hardware-configuration.nix # hardware scan results
    ./boot.nix
    # ./cachix.nix
    # ./printer.nix # NOTE: broken in 19.09 unstable
    ./display-manager.nix
    # ./steam.nix
    ./hidpi.nix

  # (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos")
  "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/release-19.09.tar.gz}/nixos"
  ];

  services.nixosManual.showManual = true;
  time.timeZone = "Europe/Zagreb";

  networking.firewall.allowedTCPPorts = [22 4200];
  networking.networkmanager.enable = true;

  virtualisation = {
    docker.enable = true;
    virtualbox.host.enable = true;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  # force password prompt for every sudo
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=0
  '';

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.brightnessctl.enable = true;
  # hardware.bluetooth.enable = true;

  # change ONLY after NixOS release notes say so (db servers can break)
  system.stateVersion = "18.09"; # Did you read the comment?

  # TODO: this does not work and services.xserver.synaptics.enable = false neither..
  # services.xserver.libinput.enable = false;
  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
    tapButtons = false;
    additionalOptions = ''
      Option "TapButton3" "2"
    '';
  };

  users.users.radivarig = {
    isNormalUser = true; # set some defaults
    extraGroups = [ "wheel" "video" "audio" "docker" "scanner" "vboxusers"];
    uid = 1000;
  };

  system.activationScripts.stuff = ''
    ln -sf /bin/sh /bin/bash # don't remember why this was needed
  '';
  home-manager.users.radivarig = import ./nix-home/home.nix;
}
