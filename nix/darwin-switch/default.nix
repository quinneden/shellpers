{
  lib,
  pkgs,
  stdenv,
  ...
}:
let
  darwin-switch = pkgs.writeShellScriptBin "darwin-switch" ''
    [[ -d $HOME/.dotfiles ]] || (echo 'error: dotfiles not found in path: ~/.dotfiles'; exit 1)
    ${lib.getExe pkgs.nh} darwin switch --hostname macos -- "$@"
  '';
in
stdenv.mkDerivation rec {
  name = "darwin-switch";
  src = ./.;
  buildInputs = [
    pkgs.nh
    darwin-switch
  ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${lib.getExe darwin-switch} $out/bin
  '';
}
