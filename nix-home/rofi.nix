{pkgs, ...}:
let
  rofiThemes = pkgs.fetchFromGitHub {
    owner = "davatorium";
    repo = "rofi-themes";
    rev = "2088c73e4006f4b17d6ce75758c6f021e612d1c2";
    sha256 = "1jydnxqc4g4h2l7xh297kpixc1dyfjdp649ayp9bvclpxz1cwgd1";
  };
in
{
  programs.rofi = {
    enable = true;
    theme = "${rofiThemes}/User Themes/arc-red-dark.rasi";
  };
}
