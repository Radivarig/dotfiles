{pkgs, ...}: with pkgs;

stdenv.mkDerivation rec {
  name = "i3blocks-${version}";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "vivien";
    repo = "i3blocks";
    rev = "3417602a2d8322bc866861297f535e1ef80b8cb0";
    sha256 = "0v8mwnm8qzpv6xnqvrk43s4b9iyld4naqzbaxk4ldq1qkhai0wsv";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];

  patchPhase = ''
    ./autogen.sh --no-configure
  '';
}
