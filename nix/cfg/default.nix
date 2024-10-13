{
  pkgs,
  stdenv,
  ...
}: let
  cfg = pkgs.writeShellScriptBin "cfg" ''
dotdir="$HOME"/.dotfiles

    parse_files() {
      read -rd'EOF' match_list < <(find $dotdir -type f -iregex ".*/$query.*\.nix")

      if [[ -z $match_list ]]; then
        echo "error: file not found"; exit 1
      else
        read -rd'EOF' match_darwin < <(printf "%s\n" $match_list | grep -i -E "darwin")
        read -rd'EOF' match_nixos < <(printf "%s\n" $match_list | grep -i -E "nixos")
        export match_darwin match_nixos
      fi
    }

    main() {
      if [[ $1 =~ ^-.$ ]]; then
        case "$1" in
          -c)
            edit='codium'
            ;;
          -a)
            EDIT_ALL=1
            edit='mi'
            ;;
        esac
        shift
      else
        edit='mi'
      fi

      export query="$1"

      parse_files

      if [[ $(uname) == 'Darwin' ]]; then
        read -rd'EOF' -a file_arr < <(printf "%s\n" $match_darwin $match_list | sort -u)
      else
        read -rd'EOF' -a file_arr < <(printf "%s\n" $match_nixos $match_list | sort -u)
      fi

      if [[ $EDIT_ALL == 1 ]]; then
        for f in "''${file_arr[@]}"; do $edit "$f"; done
      else
        $edit "''${file_arr}"
      fi
    }

    main "$@" || exit 1
  '';
in
  stdenv.mkDerivation rec {
    name = "cfg";
    src = ./.;
    buildInputs = [cfg];
    installPhase = ''
      mkdir -p $out/bin
      cp ${cfg}/bin/* $out/bin
    '';
  }
