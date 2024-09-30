{
  pkgs,
  stdenv,
  ...
}: let
  rm-result = pkgs.writeShellScriptBin "rm-result" ''
    main() {
      if [[ $# -eq 0 ]]; then
        if [[ -L ./result ]]; then
          local STORE_PATH="$(readlink ./result)"
          if [[ -e $STORE_PATH ]]; then
            rm -f ./result && echo "removed symlink: $PWD/result"
            [[ $STORE_PATH =~ '/nix/store' ]] && nix-store --delete "$STORE_PATH"
          else
            if [[ -L ./result && ! -e $STORE_PATH ]]; then
              echo "$STORE_PATH: not in nix store"
              rm -f ./result && echo "removed symlink: $PWD/result"
            fi
          fi
        else
          echo "error: no outlink found in current directory"; return 1
        fi
      else
        if [[ -L "$1" ]]; then
          local SYMLINK="$1"
          local STORE_PATH="$(readlink "$SYMLINK")"
          rm -rf "$SYMLINK" && echo "removed symlink: $PWD/$(basename $SYMLINK)"
          if [[ -e $STORE_PATH ]]; then
            [[ $STORE_PATH =~ '/nix/store' ]] && nix-store --delete "$STORE_PATH"
          else
            echo "error: no outlink found in current directory"; return 1
          fi
        fi
      fi
    }

    main "''${@}" && exit
  '';
in
  stdenv.mkDerivation rec {
    name = "rm-result";
    src = ./.;
    buildInputs = [rm-result];
    installPhase = ''
      mkdir -p $out
      cp ${rm-result}/bin/* $out
    '';
  }
