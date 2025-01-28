{
  glow,
  stdenv,
  writeShellScript,
}:
let
  script = writeShellScript "readme" ''
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
    	glow "$readme_file"
    fi
  '';
in
stdenv.mkDerivation rec {
  name = "readme";
  src = ./.;

  buildInputs = [ glow ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
