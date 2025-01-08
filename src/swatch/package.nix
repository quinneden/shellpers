{
  lib,
  pkgs,
  stdenv,
  writeShellScriptBin,
  ...
}:
let
  swatch = writeShellScriptBin "swatch" ''
    if [ -z "$1" ]; then
      echo "Usage: swatch <hex_color_code>"
      return 1
    fi


    hex_color=''${1#"#"}

    r=$((16#''${hex_color:0:2}))
    g=$((16#''${hex_color:2:2}))
    b=$((16#''${hex_color:4:2}))

    ansi_escape="\e[48;2;''${r};''${g};''${b}m      \e[0m"

    echo -e "Hex color: #$hex_color"
    echo -e "Color swatch: $ansi_escape"
    echo -e "              $ansi_escape"
  '';
in
stdenv.mkDerivation {
  name = "swatch";
  src = ./.;

  buildInputs = [
    swatch
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${lib.getExe swatch} $out/bin
  '';
}
