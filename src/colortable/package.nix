{
  lib,
  pkgs,
  stdenv,
  writeShellScriptBin,
  ...
}:
let
  colortable = writeShellScriptBin "colortable" ''
    for color in {1..225}; do
      echo -en "\033[38;5;''${color}m38;5;''${color} \n"
    done | column -x
  '';
in
stdenv.mkDerivation {
  name = "colortable";
  src = ./.;

  buildInputs = [
    colortable
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${lib.getExe colortable} $out/bin
  '';
}
