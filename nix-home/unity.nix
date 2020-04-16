{pkgs, nixos-unstable, ...}: with pkgs; {
  home.packages = [
    nixos-unstable.unityhub
    omnisharp-roslyn
    mono
    dotnet-sdk
  ];
  home.sessionVariables = {
    FrameworkPathOverride = "${mono}/lib/mono/4.7.1-api";
  };
}
