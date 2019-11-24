{ pkgs, ... }: with pkgs;
let
machine = import ./machine-settings.nix {inherit pkgs;};
in
if machine.model == "xps15"
then
{
  boot.earlyVconsoleSetup = true;
  i18n.consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";


  # fonts.fontconfig.dpi = 227;
  # services.xserver.dpi = 227;
}
else {}