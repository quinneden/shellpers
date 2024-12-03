{
  lib,
  pkgs,
  stdenv,
  system,
  ...
}:
let
  readme = pkgs.writeShellScriptBin "readme" ''
    if [[ $# -ge 1 ]]
    then
    	read -r readme_file < <(fd -i "$1" "$PWD")
    else
    	read -r readme_file < <(fd "readme" --max-depth 1 .) || read -r readme_file < <(fd "readme" --max-depth 1 ..)
    fi

    if [[ ! -f $readme_file ]]
    then
    	echo "error: file not found"
    	exit 1
    else
    	${lib.getExe pkgs.glow} $readme_file
    fi
  '';
in
stdenv.mkDerivation rec {
  name = "readme";
  src = ./.;
  buildInputs = [ readme ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${readme}/bin/* $out/bin
  '';
}
