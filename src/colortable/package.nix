{ stdenv, writeShellScript }:
let
  script = writeShellScript "colortable" ''
    for color in {1..225}; do
      echo -en "\033[38;5;''${color}m38;5;''${color} \n"
    done | column -x
  '';
in
stdenv.mkDerivation rec {
  name = "colortable";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
