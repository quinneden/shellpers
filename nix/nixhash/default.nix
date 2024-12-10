{
  lib,
  pkgs,
  stdenv,
  writeShellScriptBin,
  ...
}:
let
  nix-prefetch-url = "${pkgs.nix}/bin/nix-prefetch-url";
  nixhash = writeShellScriptBin "nixhash" ''
    URL="$1"
    PREFETCH_URL=$(${nix-prefetch-url} "$URL" 2>/dev/null)
    ${lib.getExe pkgs.nix} hash to-sri --type sha256 "$PREFETCH_URL"
  '';
in
stdenv.mkDerivation rec {
  name = "nixhash";
  src = ./.;

  buildInputs = [
    nixhash
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${lib.getExe nixhash} $out/bin
  '';
}
