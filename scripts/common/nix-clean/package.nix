{
  lib,
  nh,
  stdenv,
  writeShellScript,
}:
let
  binPath = lib.makeBinPath [ nh ];

  script = writeShellScript "nix-clean" ''
    PATH=${binPath}:$PATH

    has_argument() {
      [[ ($1 == *=* && -n ''${1#*=}) || (-n "$2" && "$2" != -*)  ]];
    }

    extract_argument() {
      echo -n "''${2:-''${1#*=}}"
    }

    while [[ $? -gt 0 ]]; do
      case "$1" in
        --keep-since | -K)
          if ! has_argument "$@"; then
            echo "error: flag '--keep-since' requires 1 arg, but 0 were given" >&2
            exit 1
          else
            arg=$(extract_argument "$@")
          fi

          flags+=("--keep-since" "''${arg%[Dd]d}")
          shift 2
          ;;

        --keep | -k)
          if ! has_argument "$@"; then
            echo "error: flag '--keep-since' requires 1 arg, but 0 were given" >&2
            exit 1
          else
            arg=$(extract_argument "$@")
          fi

          flags+=$("--keep" "''${arg%[Dd]d}")
          shift 2
          ;;

        --dry)
          flags+=("--dry")
          shift
          ;;
      esac
    done

    nh clean all --ask "''${flags[@]}"
  '';
in
stdenv.mkDerivation rec {
  name = "nix-clean";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
