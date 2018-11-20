{ pkgs, ... }: with pkgs;
{
  services.xserver.displayManager = {
    slim = {
      enable = true;
      defaultUser = "radivarig";
    };
  };

  systemd.services.lockOnClose = {
    description = "Lock X session using slimlock";
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      User = "radivarig";
      ExecStart = "${slim}/bin/slimlock";
    };
  };
}
