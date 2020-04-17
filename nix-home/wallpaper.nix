{pkgs, ...}: with pkgs;
{
  # TODO: parametrize folder and duration
  # TODO: save process id so it can be found and killed
  xsession.initExtra = ''
    while true; do
      ${pkgs.feh}/bin/feh -z --recursive --bg-max ~/spacebase/wallpapers
      sleep $((5*60))
    done &
  '';
}
