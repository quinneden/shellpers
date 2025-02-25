{
  stdenv,
  writeShellScript,
}:
let
  copyToPb = if stdenv.isDarwin then "pbcopy" else "wl-copy";

  script = writeShellScript "nixhash" ''
    usage() {
      echo "Usage: nixhash [--unpack] <URL>"
    }

    has_argument() {
      [[ ("$1" == *=* && -n ''${1#*=}) || ( -n "$2" && "$2" != -*)  ]];
    }

    extract_argument() {
      echo "''${2:-''${1#*=}}"
    }

    is_url() {
      [[ $1 =~ http[s]?://[[:alnum:]] ]]
    }

    confirm() {
      while true; do
        read -r -n 1 -p "$1 [y/n]: " REPLY
        case $REPLY in
          [yY]) echo ; return 0 ;;
          [nN]) echo ; return 1 ;;
          *) echo ;;
        esac
      done
    }

    if [[ $# -eq 0 ]]; then
      usage; exit 0
    fi

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -u | --unpack)
          if ! has_argument "$@"; then
            echo "error: url not specified" >&2
            exit 1
          fi

          UNPACK=true

          URL=$(extract_argument "$@")

          if ! is_url "$URL"; then
            echo "error: malformed url" >&2
            exit 1
          fi

          shift 2
          ;;

        *)
          if ! is_url "$@"; then
            echo "error: malformed url" >&2
            exit 1
          fi

          URL="$1"; shift
          ;;
      esac
    done

    if [[ $UNPACK == true ]]; then
      PREFETCH_URL=$(nix-prefetch-url --unpack "$URL" 2>/dev/null)
    else
      PREFETCH_URL=$(nix-prefetch-url "$URL" 2>/dev/null)
    fi

    if [[ -z $PREFETCH_URL ]]; then
      echo "error: unable to prefetch url"
      exit 1
    fi

    HASH=$(nix hash to-sri --type sha256 "$PREFETCH_URL" | tr -d '\n')
    echo $HASH
    echo

    confirm "Copy to clipboard?" || exit 0

    printf "$HASH" | ${copyToPb}
  '';
in
stdenv.mkDerivation rec {
  name = "nixhash";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
