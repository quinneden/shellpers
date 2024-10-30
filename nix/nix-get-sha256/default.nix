{
  pkgs,
  stdenv,
  ...
}:
let
  nix-get-sha256 = pkgs.writeShellScriptBin "nix-get-sha256" ''
    URL="$1"

    read -r PREFETCH_URL < <(nix-prefetch-url "$URL" 2>/dev/null)

    if [[ ${#PREFETCH_URL} -eq 52 ]]; then
      nix hash to-sri --type sha256 "$PREFETCH_URL"
    else
      echo "error: couldn't prefetch url"
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
