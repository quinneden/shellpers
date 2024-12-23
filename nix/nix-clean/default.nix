{
  lib,
  pkgs,
  stdenv,
  writeShellScript,
  writeShellScriptBin,
  ...
}:
let
  #   collect-garbage = writeShellScript "collect-garbage" ''
  #     DELETE_OLD="''${DELETE_OLD:-false}"
  #     DAYS="''${DAYS:-}"
  #
  #     if $DELETE_OLD; then
  #       if [[ -n $DAYS ]]; then
  #         opts=("--keep-since" "$DAYS")
  #       else
  #         opts=("-d")
  #       fi
  #     fi
  #
  #     read -ra arr1 < <(sudo nix-collect-garbage ''${opts[@]})
  #     read -ra arr2 < <(nix-collect-garbage ''${opts[@]})
  #     read -r store_paths < <(awk "BEGIN {print ''${arr1[0]}+''${arr2[0]}; exit}")
  #     read -r mib_float < <(awk "BEGIN {print ''${arr1[4]}+''${arr2[4]}; exit}")
  #     printf "%s" "$store_paths $mib_float"
  #   '';

  nix-clean = writeShellScriptBin "nix-clean" ''
    has_argument() {
      [[ ("$1" == *=* && -n ''${1#*=}) || ( -n "$2" && "$2" != -*)  ]];
    }

    extract_argument() {
      echo "''${2:-''${1#*=}}"
    }

    while [[ $? -gt 0 ]]; do
      case "$1" in
        --keep-since)
          if ! has_argument "$@"; then
            echo "error: flag '--keep-since' requires 1 arg, but 0 were given" >&2
            exit 1
          fi

          KEEP_SINCE=$(extract_argument "$@")
          shift 2
          ;;

        -k | --keep)
          if ! has_argument "$@"; then
            echo "error: flag '--keep-since' requires 1 arg, but 0 were given" >&2
            exit 1
          fi

          KEEP=$(extract_argument "$@")
          shift 2

        --dry)
          DRY=true
          shift
          ;;
      esac
    done

    if [[ -n $KEEP_SINCE ]]; then
      flags+=( "--keep-since" "''${KEEP_SINCE%d}d")
    fi

    if [[ -n $KEEP && -z $KEEP_SINCE ]]; then
      flags+=( "--keep" "$KEEP")
    fi

    if [[ $DRY == true ]]; then
      flags+=("--dry")

    nh clean all --ask "''${flags[@]}"
  '';
in
stdenv.mkDerivation rec {
  name = "nix-clean";
  src = ./.;
  nativeBuildInputs = [ pkgs.nh ];
  buildInputs = [ nix-clean ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${lib.getExe nix-clean} $out/bin
  '';
}
