{pkgs, ...}: with pkgs;
{
  home.packages = [
    haskellPackages.greenclip
  ];
  xdg.configFile."greenclip.cfg".source = ./greenclip.cfg;
}

