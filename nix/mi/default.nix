{
  lib,
  pkgs,
  stdenv,
  ...
}:
let
  mi = pkgs.writeShellScriptBin "mi" (
    if stdenv.isLinux then
      ''
        echo -ne '\e[6 q'; ${lib.getExe pkgs.micro} "$@"; echo -ne '\e[6 q'
      ''
    else
      ''
        ${lib.getExe pkgs.micro} "$@"
      ''
  );
in
stdenv.mkDerivation rec {
  name = "mi";
  src = ./.;
  buildInputs = [ mi ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${lib.getExe mi} $out/bin
  '';
}
