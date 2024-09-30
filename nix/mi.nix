{
  pkgs,
  stdenv,
  ...
}: let
  mi = pkgs.writeShellScriptBin "mi" ''
    if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
      micro "$@"
    else
      echo -ne '\e[6 q'
      micro $@
      echo -ne '\e[2 q'
    fi
  '';
in
  stdenv.mkDerivation rec {
    name = "mi";
    src = ./.;
    buildInputs = [mi];
    installPhase = ''
      mkdir -p $out
      cp ${mi}/bin/* $out
    '';
  }
