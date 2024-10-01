{pkgs, ...}: pkgs.writeShellScriptBin "mi" ''
  OS_RELEASE=$(cat /etc/os-release)
  if [[ $(grep '^ID' <<<$OS_RELEASE) =~ nixos ]]; then
    echo -ne '\e[6 q'
    micro $@
    echo -ne '\e[2 q'
  else
    micro "$@"
  fi
''
