{pkgs, ...}:
let
  mod = "Mod4"; # TODO: use module options tom take this from i3/default.nix config.modifier
  lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 111111";
in
{
  services.screen-locker.enable = true;
  services.screen-locker.lockCmd = lockCmd;

  xsession.windowManager.i3 = rec {
    config.keybindings = {
      "${mod}+Escape" = "exec ${lockCmd}";
    };
  };
}