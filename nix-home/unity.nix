{pkgs, ...}: with pkgs;
let
  fetchurl = _: pkgs.fetchurl {
    url = "https://public-cdn.cloud.unity3d.com/hub/prod/UnityHub.AppImage";
    sha256 = "05p5kqbwgqyk2aw2lix5dk1ql16aj6iczxrc63a1l0vj8wrha7z4";
  };

  unityhub-fixed = pkgs.unityhub.override (_: { inherit fetchurl; });
in
{
  home.packages = [
    unityhub-fixed
    omnisharp-roslyn
    mono
    dotnet-sdk
  ];
}
