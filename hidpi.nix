{ pkgs, ... }: with pkgs;
let
machine = import ./machine-settings.nix {inherit pkgs;};
in
if machine.model == "xps15"
then
{
  console.earlySetup = true;
  console.font = "ter-i32b";
  console.packages = with pkgs; [ terminus_font ];
}
else {
}
