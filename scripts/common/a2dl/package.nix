{
  aria2,
  lib,
  writeShellScriptBin,
}:

let
  binPath = lib.makeBinPath [ aria2 ];
in

writeShellScriptBin "a2dl" ''
  PATH="${binPath}:$PATH"
  URL="$1"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -x)
        max_conn="$1"
        shift
        ;;
      -j)
        max_dl="$1"
        shift
        ;;
    esac
  done

  if [[ "$URL" =~ ^http[s]*:// ]]; then
    output_dir="''${2:-$PWD}"
    aria2c "$URL" \
      --max-connections-per-server=''${max_conn:-16} \
      --max-concurrent-downloads=''${max_dl:-5} \
      --dir="$output_dir"
  else
    echo "error: malformed url" >&2
    exit 1
  fi
''
