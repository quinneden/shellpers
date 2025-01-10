{
  nh,
  stdenv,
  writeShellScript,
}:
let
  script = writeShellScript "nix-clean" ''
    has_argument() {
      [[ ($1 == *=* && -n ''${1#*=}) || ( -n "$2" && "$2" != -*)  ]];
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
          ;;

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
    fi

    nh clean all --ask "''${flags[@]}"
  '';
in
stdenv.mkDerivation rec {
  name = "nix-clean";
  src = ./.;

  nativeBuildInputs = [ nh ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
