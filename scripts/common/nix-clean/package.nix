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

    blue="\033[96m"
    yellow="\033[93m"
    reset="\033[0m"

    optimise=false

    has_argument() {
      [[ ($1 == *=* && -n ''${1#*=}) || (-n "$2" && "$2" != -*)  ]];
    }

    extract_argument() {
      echo -n "''${2:-''${1#*=}}"
    }

    get_size() {
      diskutil list -plist virtual | plutil -convert json -o - - |
      jq '
        .AllDisksAndPartitions
        | .[]
        | select(.DeviceIdentifier == "disk3")
        | .APFSVolumes[]
        | select(.MountPoint == "/nix")
        | .CapacityInUse
      ' | numfmt --to si
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

        -o | --optimise | --optimize)
          optimise=true
          shift
          ;;
      esac
    done

    (nh clean all "''${flags[@]}" &>/dev/null) &
    pid=$!

    while kill -0 "$pid" 2>/dev/null; do
      current_size=$(get_size)
      echo -ne "''${yellow}Cleaning...''${reset}"
      echo -ne "\r''${yellow}Nix Store Size:$reset ''${blue}$current_size$reset\r"
    done

    if $optimise; then
      nix store optimise
    fi
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
