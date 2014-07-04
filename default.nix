{ pkgs ? (import <nixpkgs> {})
, stdenv ? pkgs.stdenv
, go ? pkgs.go
, git ? pkgs.git
}:

let
  gitref = { name, source }:
    import (
      pkgs.runCommand "${name}-gitref"
      { }
      ''
      echo -n '"'`${pkgs.git}/bin/git -C ${source} rev-parse HEAD`'"' > $out
      ''
    );
in
stdenv.mkDerivation rec {
  git_version = gitref { name = "direnv"; source = ./.; };
  version = "1.0.0-${git_version}";
  name = "direnv-${version}";
  src = ./.;

  buildInputs = [ go ];
  buildPhase = "make";
  installPhase = ''make install "DESTDIR=$out"'';
  dontStrip = 1;

  meta = {
    homepage = "http://direnv.net";
    description = "path-dependent environments";
    maintainers = [
      stdenv.lib.maintainers.zimbatm
    ];
    license = stdenv.lib.licenses.mit;
    platforms = go.meta.platforms;
  };
}

