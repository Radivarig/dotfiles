{pkgs, ...}: with pkgs; {
  home.packages = [
    unstable.unityhub
    omnisharp-roslyn
    mono
    dotnet-sdk
  ];
  home.sessionVariables = {
    FrameworkPathOverride = "${mono}/lib/mono/4.7.1-api";
  };
}
