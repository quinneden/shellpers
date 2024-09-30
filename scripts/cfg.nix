{pkgs, ...}:
pkgs.writeShellScriptBin "cfg" ''
  dotdir="$HOME"/.dotfiles
  set_edit() {
    if [[ $1 == '-c' ]]; then
      shift; edit='codium'; export edit
    else
      edit='mi'; export edit
    fi
  }
  find_file() {
    read -rd'EOF' CONFIGFILE < <(find $dotdir -type f -iregex ".*/$1.nix" | awk '{ print length(), $0 | "sort -n" }' | sed s/"^[0-9][0-9] "/""/g)
    if [[ -z $CONFIGFILE ]]; then
      if [[ $# -ge 1 ]]; then
        echo "error: no files matching \"$1\" found in $dotdir"
        return 1
      else
        $edit $dotdir/flake.nix
      fi
    else
      if [[ $(printf $CONFIGFILE | wc -l) -gt 1 ]]; then
        if [[ $(uname) == 'Linux' && $CONFIGFILE =~ nixos ]]; then
          read -rd'EOF' HEADFILE < <(printf $CONFIGFILE | grep -E "nixos|home-manager" | head -n 1)
          export HEADFILE
        elif [[ $(uname) == 'Darwin' && $CONFIGFILE =~ darwin ]]; then
          read -rd'EOF' HEADFILE < <(printf $CONFIGFILE | grep -E "darwin|home-manager" | head -n 1)
          export HEADFILE
        fi
      else
        read -rd'EOF' HEADFILE < <(printf $CONFIGFILE | head -n 1)
        export HEADFILE
      fi
    fi
  }
  main() {
    set_edit "$@"
    find_file "$@"
    if [[ $# -ge 1 && $? -eq 0 ]]; then
      "$edit" "$HEADFILE"
    else
      [[ $? -eq 0 ]] && "$edit" "$dotdir"/flake.nix
    fi
    # echo "$HEADFILE"
  }
  main "$@" && exit
''
