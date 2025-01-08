{
  lib,
  pkgs,
  stdenv,
  writeShellScriptBin,
  ...
}:
let
  clone = writeShellScriptBin "clone" ''
    if [[ $1 == */* && $1 != http* ]]; then
      owner=$(echo "$1" | cut -f 1 -d'/')
      repo=$(echo "$1" | cut -f 2 -d'/')
      if [[ $? -eq 2 ]]; then
        ${lib.getExe pkgs.git} clone https://github.com/"$owner"/"$repo" "$2"
      else
        ${lib.getExe pkgs.git} clone https://github.com/"$owner"/"$repo"
      fi
    elif [[ $1 == http* ]]; then
      url="$1"
      owner=$(echo $url | ${lib.getExe pkgs.gawk} -F'/' '{print $(NF-1)}')
      repo=$(echo $url | ${lib.getExe pkgs.gawk} -F'/' '{print $NF}' | ${lib.getExe pkgs.gnused} 's/\.git//g')
      if [[ $? -eq 2 ]]; then
        ${lib.getExe pkgs.git} clone https://github.com/"$owner"/"$repo" "$repo"
      else
        ${lib.getExe pkgs.git} clone https://github.com/"$owner"/"$repo" "$2"
      fi
    fi
  '';
in
stdenv.mkDerivation {
  name = "clone";
  src = ./.;

  buildInputs = [
    clone
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${lib.getExe clone} $out/bin
  '';
}
