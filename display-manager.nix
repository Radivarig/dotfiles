{ pkgs, ... }: with pkgs;
{
  services.xserver.displayManager = {
    lightdm = {
      enable = true;
    };
  };
}
