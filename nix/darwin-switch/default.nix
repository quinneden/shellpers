{
  lib,
  pkgs,
  stdenv,
  ...
}:
let
  darwin-switch = pkgs.writeShellScriptBin "darwin-switch" ''
    if [[ ! -d $HOME/.dotfiles ]]; then
      echo "error: $HOME/.dotfiles: directory not found" >&2
      exit 1
    fi

    nh darwin switch --hostname macos -- "$@"

    rm -rf ./result
  '';
in
stdenv.mkDerivation rec {
  name = "darwin-switch";

  src = ./.;

  nativeBuildInputs = [ pkgs.nh ];

  buildInputs = [ darwin-switch ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${lib.getExe darwin-switch} $out/bin
  '';
}
