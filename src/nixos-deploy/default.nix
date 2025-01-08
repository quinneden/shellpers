{
  lib,
  pkgs,
  stdenv,
  ...
}:
let
  nixos-deploy = pkgs.writeShellScriptBin "nixos-deploy" ''
    if [[ $# -eq 2 ]]; then
      flakeref="$1"
      target="$2"
    else
      echo 'error: must provide flakeref and target host'; exit 1
    fi

    [[ $target =~ 'root' ]] || IF_NOT_ROOT="--use-remote-sudo"

    "${lib.getExe pkgs.nixos-rebuild}" switch --fast --show-trace --flake "$flakeref" --target-host "$target" $IF_NOT_ROOT
  '';
in
stdenv.mkDerivation {
  name = "nixos-deploy";
  src = ./.;
  buildInputs = [ nixos-deploy ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${nixos-deploy}/bin/* $out/bin
  '';
}
