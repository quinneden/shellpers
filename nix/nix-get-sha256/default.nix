{
  pkgs,
  stdenv,
  ...
}:
let
  nix-get-sha256 = pkgs.writeShellScriptBin "nix-get-sha256" ''
    URL="$1"
    nix-prefetch-url --unpack "$URL" 2>/dev/null | read -r PREFETCH_URL
    if [[ $? -eq 0 ]]; then
      nix hash to-sri --type sha256 "$PREFETCH_URL"
    fi
  '';
in
stdenv.mkDerivation rec {
  name = "nix-get-sha256";
  src = ./.;
  buildInputs = [ nix-get-sha256 ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${nix-get-sha256}/bin/* $out/bin
  '';
}
