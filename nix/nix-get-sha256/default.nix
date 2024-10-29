{
  pkgs,
  stdenv,
  ...
}:
let
  nix-get-sha256 = pkgs.writeShellScriptBin "nix-get-sha256" ''
    if [[ $@ =~ '-u' || $@ =~ '--unpack' ]]; then
      OPT='--unpack'
    fi
    URL="$1"
    read -r PREFETCH_URL < <(nix-prefetch-url $OPT "$URL" 2>/dev/null | tr -d '\n')
    if [[ ${#PREFETCH_URL} -eq 52 ]]; then
      nix hash to-sri --type sha256 "$PREFETCH_URL"
    else
      echo "error: couldn't prefetch url" && exit 1
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
