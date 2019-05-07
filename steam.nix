{pkgs, ...}: with pkgs;
let
user = "radivarig"; # TODO: use module options tom take this from configuration.nix
in {
  hardware.opengl.driSupport32Bit = true;

  home-manager.users."${user}" = {
    home.packages = [steam];

  };
}
