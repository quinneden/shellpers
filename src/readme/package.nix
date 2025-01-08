{
  lib,
  pkgs,
  stdenv,
  ...
}:
let
  readme = pkgs.writeShellScriptBin "readme" ''
    if [[ -n $1 ]]
    then
    	readme_file="$1"
    else
      if git status &>/dev/null; then
        toplevel=$(git rev-parse --show-toplevel)
        readme_file=$(fd -i "README" "$toplevel")
      else
    	  readme_file=$(fd -i "README" --max-depth 1 . || fd -i "README" --max-depth 1 ..)
    	fi
    fi

    if [[ -z $readme_file ]]
    then
    	echo "error: file not found"
    	exit 1
    else
    	PAGER="bat --file-name $(basename $readme_file)"
    	glow "$readme_file"
    fi
  '';
in
stdenv.mkDerivation {
  name = "readme";
  src = ./.;

  nativeBuildInputs = with pkgs; [
    bat
    glow
  ];

  buildInputs = [ readme ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${lib.getExe readme} $out/bin
  '';
}
