{ pkgs, ... }: with pkgs;
{
  services.xserver = {
    enable = true;
    exportConfiguration = true;
    resolutions = [{x = 1920; y = 1080;}];
  };
}
