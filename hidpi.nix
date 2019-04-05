{ pkgs, ... }: with pkgs;
let
machine = import ./machine-settings.nix {inherit pkgs;};
in
if machine.model == "xps15"
then
{
  boot.earlyVconsoleSetup = true;
  i18n.consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  services.xserver.dpi = 220;
}
else {}