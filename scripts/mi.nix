{pkgs, ...}:
pkgs.writeShellScriptBin "mi" ''
  if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
    micro "$@"
  else
    echo -ne '\e[6 q'
    micro $@
    echo -ne '\e[2 q'
  fi
''
