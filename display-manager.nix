{ pkgs, ... }: with pkgs;
{
  services.xserver.displayManager = {
    slim = {
      enable = true;
      defaultUser = "radivarig";
    };
  };
}
