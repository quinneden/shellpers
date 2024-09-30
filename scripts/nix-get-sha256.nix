{pkgs, ...}: pkgs.writeShellScriptBin "nix-get-sha256" ''
  URL="$1"
  nix-prefetch-url --unpack "$URL" 2>/dev/null | read -r PREFETCH_URL
  if [[ $? -eq 0 ]]; then
    nix hash to-sri --type sha256 "$PREFETCH_URL"
  fi
''
