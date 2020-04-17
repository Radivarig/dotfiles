{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    # sudo nix-channel --add https://nixos.org/channels/nixos-unstable
    unstable = import <nixos-unstable> {config = config.nixpkgs.config;};
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.chromium.enable = true;

  xsession.enable = true;

  services.compton = {
    enable = true;
    vSync = "opengl-swc";
  };

  imports = [
    ./termite.nix
    ./i3/default.nix
    ./screen-locker.nix
    ./git.nix
    ./rofi.nix
    ./input-remaps.nix
    ./ranger.nix

    ./bash-history.nix
    ./bash-stuff.nix

    ./packages.nix
    ./greenclip.nix
    ./unity.nix
    ./wallpaper.nix
  ];
}
