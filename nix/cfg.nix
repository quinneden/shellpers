{pkgs, stdenv, ...}: let
  cfg = pkgs.writeShellScriptBin "cfg" ''
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

    # new_file() {
    #   if [[ -d $dotdir/$1 ]]; then
    #     local subdir="$dotdir/$1"
    #     if [[ -f $subdir/$2 ]]; then
    #       echo "error: file exists"; exit 1
    #     else
    #       if [[ $2 =~ '\.nix' ]]; then
    #         printf '{\n  \n}' > "$subdir/$2" || exit 1
    #         newfile="$subdir/$2"
    #       else
    #         printf '{\n  \n}' > "$subdir/$2.nix" || exit 1
    #         newfile="$subdir/$2.nix"
    #       fi
    #       "$edit" "$newfile"
    #     fi
    #   else
    #     echo "error: path not found"; exit 1
    #   fi
    # }

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
  '';
in
  stdenv.mkDerivation rec {
    name = "cfg";
    src = ./.;
    buildInputs = [cfg];
    installPhase = ''
      mkdir -p $out
      cp ${cfg}/bin/* $out
    '';
  }
