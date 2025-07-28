{
  coreutils,
  lib,
  jq,
  nh,
  stdenv,
  writeShellScript,
}:
let
  inherit (import ../../../lib) colors;

  binPath =
    with lib;
    makeBinPath ([ nh ] ++ optional stdenv.isDarwin jq ++ optional stdenv.isLinux coreutils);

  script = writeShellScript "nix-clean" ''
    PATH=${binPath}:$PATH

    flags=()
    optimize=false

    ${
      if stdenv.isDarwin then
        ''
          get_size_bytes() {
            diskutil list -plist virtual | plutil -convert json -o - - | jq '
              .AllDisksAndPartitions
              | .[] | .APFSVolumes[]?
              | select(.MountPoint == "/nix")
              | .CapacityInUse
            '
          }
        ''
      else
        ''
          get_size_bytes() {
            df --output=used /nix | tail -n1
          }
        ''
    }

    show_help() {
      echo "Usage: nix-clean [OPTIONS]" >&2
      echo >&2
      echo "Options:" >&2
      echo "  -h, --help                   Show this help message" >&2
      echo "  -k, --keep KEEP              Specify number of past generations to keep" >&2
      echo "  -K, --keep-since KEEP_SINCE  Specify time range in which past gcroots and generations will be kept" >&2
      echo "  -O, --optimize               Optimize the Nix store after cleaning" >&2
      echo "  -u, --used                   Show the current size of the Nix store and exit" >&2
      echo "  -v, --verbose                Show debug logs" >&2
    }

    nh_clean_in_background() {
      nh clean all "$@" &>/dev/null &
      nh_pid=$!
      trap "sudo kill $nh_pid &>/dev/null" INT TERM EXIT
    }

    to_mib() {
      local bytes
      if [[ $# -eq 1 ]]; then
        bytes=$1
      else
        read -r bytes
      fi
      awk -v b="$bytes" 'BEGIN { printf "%.2f MiB\n", b/1048576 }'
    }

    to_gib() {
      local bytes
      if [[ -n $1 ]]; then
        bytes=$1
      else
        read -r bytes
      fi
      awk -v b="$bytes" 'BEGIN { printf "%.2f GiB\n", b/1073741824 }'
    }

    get_percentage() {
      awk -v num="$bytes_diff" -v den="$initial_bytes" -v prec=2 \
        'BEGIN { printf "%.*f", prec, (num/den)*100 }'
    }

    show_diff() {
      local current_bytes bytes_diff
      current_bytes=$(get_size_bytes)
      bytes_diff=$((initial_bytes - current_bytes))
      pct="$(get_percentage "$bytes_diff" "$initial_bytes")%"

      if [[ $bytes_diff -gt $((1024 * 1024 * 1024)) ]]; then
        fmt=$(to_gib "$bytes_diff")
      elif [[ $bytes_diff -gt 0 ]]; then
        fmt=$(to_mib "$bytes_diff")
      else
        fmt="0.00 MiB"
      fi

      echo "$fmt, $pct"
    }

    watch_clean_until_done() {
      while kill -0 "$nh_pid" 2>/dev/null; do
        echo -ne "Cleaning.    [ ${colors.YELLOW}$(show_diff) removed${colors.RESET} ]\r"; sleep 0.5
        echo -ne "Cleaning..   [ ${colors.YELLOW}$(show_diff) removed${colors.RESET} ]\r"; sleep 0.5
        echo -ne "Cleaning...  [ ${colors.YELLOW}$(show_diff) removed${colors.RESET} ]\r"; sleep 0.7
        echo -ne "Cleaning     [ ${colors.YELLOW}$(show_diff) removed${colors.RESET} ]\r"; sleep 0.3
      done
      echo -ne "                                        \r"
    }

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -h | --help)
          show_help
          exit 0
          ;;
        -k | --keep)
          if [[ -z $2 || $2 == -* ]]; then
            echo "${colors.RED}Error: option requires 1 argument, but 0 were given${colors.RESET}" >&2
            exit 1
          fi
          flags+=("--keep" "$2")
          shift 2
          ;;
        -K | --keep-since)
          if [[ -z $2 || $2 == -* ]]; then
            echo "${colors.RED}Error: option requires 1 argument, but 0 were given${colors.RESET}" >&2
            exit 1
          fi
          flags+=("--keep-since" "$2")
          shift 2
          ;;
        -u | --used)
          echo -e "Nix store size: ${colors.YELLOW}$(get_size_bytes | to_gib)${colors.RESET}"
          exit 0
          ;;
        -O | --optimize | --optimise)
          optimize=true
          shift
          ;;
        -v | --verbose)
          flags+=("--verbose")
          shift
          ;;
        *)
          echo "${colors.RED}Error: Unknown option '$1'${colors.RESET}" >&2
          show_help
          exit 1
          ;;
      esac
    done

    initial_bytes=$(get_size_bytes)
    nh_clean_in_background "''${flags[@]}"

    if watch_clean_until_done; then
      echo -e "${colors.GREEN}Finished cleaning Nix store!${colors.RESET}"
      echo -e "Remaining:  ${colors.YELLOW}$(get_size_bytes | to_gib)${colors.RESET}"
      echo -e "Removed:    ${colors.YELLOW}$(show_diff)${colors.RESET}"
    fi

    if "$optimize"; then
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
