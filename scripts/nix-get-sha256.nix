{pkgs, ...}:
pkgs.writeShellScriptBin "nix-get-sha256" ''
  main() {
    if [[ $# -eq 1 ]]; then
      URL="$1"
    else
      echo "error: no input"
    fi

    read -r PREFETCH_URL < <(${pkgs.nix}/bin/nix-prefetch-url --unpack "$URL" 2>/dev/null)

    if [[ -n $PREFETCH_URL ]]; then
      read -r HASH < <(${pkgs.nix}/bin/nix hash to-sri --type sha256 "$PREFETCH_URL")
      printf "\n{\n  \"url\": \"$URL\",\n  \"hash\": \"$HASH\"\n}\n"
    else
      echo "error: couldn't prefetch url"
    fi
  }
  main "$@" || exit 1
''
