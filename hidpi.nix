{ pkgs, ... }: with pkgs;
let
machine = import ./machine-settings.nix {inherit pkgs;};
in
if machine.model == "xps15"
then
{
  console.earlySetup = true;
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
}
else {
}
