{pkgs, ...}:
with pkgs;
let
user = "radivarig"; # TODO: use module options tom take this from configuration.nix
conf = import ./conf.nix {inherit pkgs;};
in {
  home-manager.users."${user}" = {
    home.packages = [lxterminal];
    services.compton.opacityRule = ["70:class_g *= 'Lxterminal'"];
    home.sessionVariables = {TERMINAL="lxterminal";};
    home.file.".config/lxterminal/lxterminal.conf".text = conf;
  };
}
