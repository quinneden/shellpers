{ writeShellScriptBin }:

writeShellScriptBin "lsh" ''
  lima_json=$(limactl list --json | jq -r '{name: .name, status: .status}')

  parse_args() {
    if [[ $# -eq 0 ]]; then
      instance="default"
    else
      if [[ $1 == '-s' ]]; then
        shift; STOP=1
      fi
      instance="$1"
    fi
  }

  stop_instance() {
    if [[ $STOP -eq 1 ]]; then
      if jq -re --arg instance "$instance" 'select(.name == $instance)' <<<$lima_json &>/dev/null; then
        limactl stop "$instance" && exit 0
      fi
    fi
  }

  lima_shell() {
    if jq -re --arg instance "$instance" 'select(.name == $instance)' <<<$lima_json &>/dev/null; then
      if [[ $(jq -r --arg instance "$instance" 'select(.name == $instance) | .status' <<<$lima_json) == 'Stopped' ]]; then
        limactl start $instance || return 1
      fi
      limactl shell $instance
    fi
  }

  main() {
    parse_args "$@"
    stop_instance
    lima_shell
  }

  main "$@" || exit 1
''
