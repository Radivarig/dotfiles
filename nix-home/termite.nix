{pkgs, ...}: with pkgs; {
  programs.termite = {
    enable = true;
    scrollbackLines = 100000;
    searchWrap = false;
    clickableUrl = false;
    backgroundColor = "rgba(0,0,0,1)";
    foregroundColor = "rgba(255,255,255,1)";
    colorsExtra = ''
      color0 = rgba(0,0,0,1)
      color1 = rgba(219,45,32,1)
      color2 = rgba(0,162,82,1)
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

  services.picom.opacityRule = [
    "70:class_g *= 'Termite'"
  ];

  home.sessionVariables = {TERMINAL="termite";};
}
