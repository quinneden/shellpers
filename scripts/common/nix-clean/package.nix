{
  coreutils,
  lib,
  nh,
  stdenv,
  writeShellScript,
}:
let
  binPath = lib.makeBinPath [
    nh
    coreutils
  ];

  script = writeShellScript "nix-clean" ''
    PATH=${binPath}:$PATH
    optimise=false

    GREEN='\033[32m'
    RESET='\033[0m'

    has_argument() {
      [[ ($1 == *=* && -n ''${1#*=}) || (-n "$2" && "$2" != -*)  ]];
    }

    extract_argument() {
      echo -n "''${2:-''${1#*=}}"
    }

    ${
      if stdenv.hostPlatform == "aarch64-linux" then
        ''
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
        ''
      else
        ''
          get_size() {
            df -h --output=used /nix | tail -n1 | xargs
          }
        ''
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
      echo -ne "Cleaning.   (current size: $current_size)\r"; sleep 0.5
      echo -ne "Cleaning..  (current size: $current_size)\r"; sleep 0.5
      echo -ne "Cleaning... (current size: $current_size)\r"; sleep 0.7
      echo -ne "Cleaning    (current size: $current_size)\r"; sleep 0.3
    done && echo -e "\n''${GREEN}Done!''${RESET}"

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
