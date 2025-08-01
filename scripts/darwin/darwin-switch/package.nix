{
  lib,
  nh,
  writeShellScriptBin,
}:

let
  binPath = lib.makeBinPath [ nh ];
in

writeShellScriptBin "darwin-switch" ''
  PATH=${binPath}:$PATH

  ext_opts=()
  nh_opts=()

  while [[ $# -gt 0 ]]; do
    case $1 in
      --help|-h)
        echo "Usage: darwin-switch [options]"
        echo "Options:"
        echo "  -a, --ask           Ask for confirmation before switching"
        echo "  -h, --help          Display this help message"
        echo "  -H, --hostname      Specify the hostname"
        echo "  -n, --dry           Dry run, do not actually switch"
        echo "  -N, --no-nom        Don't use nix-output-monitor"
        echo "  -o, --out-link      Specify the name of the output link"
        echo "  -u, --update        Update all the flake inputs"
        echo "  -U, --update-input  Update a single flake input"
        echo "  -v, --verbose       Enable verbose output"
        exit 0
        ;;
      -a | --ask | -n | --dry | --no-nom | -u | --update | -v | --verbose)
        nh_opts+=("$1")
        shift
        ;;
      -H | --hostname | -o | --out-link | -U | --update-input)
        nh_opts+=("$1" "$2")
        shift 2
        ;;
      -*)
        if [[ ($1 == *=* && -n ''${1#*=}) || (-n "$2" && "$2" != -*)  ]]; then
          arg="''${2:-''${1#*=}}"
          extra_opts+=("''${1#*=}" "$arg")
          if [[ $1 == *=* && -n ''${1#*=}= ]]; then
            shift
          else
            shift 2
          fi
        else
          extra_opts+=("$1")
          shift
        fi
        ;;
      *)
        echo "error: unknown option: $1" >&2
        exit 1
        ;;
    esac
  done

  if [[ ! -d $HOME/.dotfiles ]]; then
    echo "error: $HOME/.dotfiles: directory not found" >&2
    exit 1
  fi

  nh darwin switch "''${nh_opts[@]}" -- "''${extra_opts[@]}"
''
