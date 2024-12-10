{
  lib,
  pkgs,
  stdenv,
  writeShellScriptBin,
  ...
}:
let
  adl = writeShellScriptBin "adl" ''
    URL="$1"
    if [[ "$URL" =~ ^http[s]*:// ]]; then
      output_dir="''${2:-$PWD}"
      "${lib.getExe pkgs.aria2}" "$URL" -d "$output_dir"
    else
      echo "error: malformed url"; exit 1
    fi
  '';
in
stdenv.mkDerivation rec {
  name = "adl";
  src = ./.;

  buildInputs = [
    adl
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${lib.getExe adl} $out/bin
  '';
}
