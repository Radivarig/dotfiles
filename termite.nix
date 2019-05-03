{pkgs, ...}: with pkgs;
let
user = "radivarig"; # TODO: use module options tom take this from configuration.nix
in {
  home-manager.users."${user}" = {
    programs.termite = {
      enable = true;
      scrollbackLines = 10000;
      cursorBlink = "off"; # TODO set system wide
      backgroundColor = "rgba(0,0,0,1)";
      foregroundColor = "rgba(255,255,255,1)";
      colorsExtra = ''
        color0 = rgba(0,0,0,1)
        color1 = rgba(170,0,0,1)
        color2 = rgba(0,170,0,1)
        color3 = rgba(170,85,0,1)
        color4 = rgba(100,100,255,1)
        color5 = rgba(170,0,170,1)
        color6 = rgba(0,170,170,1)
        color7 = rgba(170,170,170,1)
        color8 = rgba(85,85,85,1)
        color9 = rgba(255,85,85,1)
        color10 = rgba(85,255,85,1)
        color11 = rgba(255,255,85,1)
        color12 = rgba(85,85,255,1)
        color13 = rgba(255,85,255,1)
        color14 = rgba(85,255,255,1)
        color15 = rgba(255,255,255,1)
      '';
    };

    services.compton.opacityRule = [
      "70:class_g *= 'Termite'"
    ];

    home.sessionVariables = {TERMINAL="termite";};
  };
}
