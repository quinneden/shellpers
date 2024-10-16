{
  pkgs,
  stdenv,
  ...
}:
let
  fuck = pkgs.writeShellScriptBin "fuck" ''
    parse_args() {
      for f in "''${@}"; do
        if [[ -L $f ]]; then
          files+=("$f")
        elif [[ -e $f ]]; then
          files+=("$(realpath $f 2>/dev/null)")
        else
          echo "error: path does not exist"
          exit 1
        fi
      done

      for i in "''${PROTECT[@]}"; do
        for f in "''${files[@]}"; do
          if [[ $f =~ $i ]]; then
            echo "error: cannot delete protected file or directory: $f"
            exit 1
          fi
        done
      done
    }

    trash_files() {
      if [[ $(uname) == 'Linux' ]]; then
        owner=$(stat -c "%u" $f)
      else
        owner=$(stat -f "%u" $f)
      fi

      if [[ -n ''${files} ]]; then
        for f in "''${files[@]}"; do
          if [[ $owner -eq 0 ]]; then
            eval sudo $trash_cmd "$f"
          else
            eval $trash_cmd "$f"
          fi
        done
      fi

      if [[ $? -eq 0 ]]; then
        local LIST_DEL=$(for f in "''${files[@]}"; do printf "  $(basename $f)\n"; done)
        printf "Deleted:\n$LIST_DEL\n"
      fi
    }

    empty_trash() {
      if [[ $EMPTY_NOW -eq 1 ]]; then
        $trash_empty_cmd "''${files[@]}" &>/dev/null
      else
        ((sleep 60 && $trash_empty_cmd "''${files[@]}" &>/dev/null) &)
      fi
    }

    main() {
      local files=()
      local PROTECT=($HOME/.dotfiles$ $HOME/workdir$ $HOME/repos$ $HOME/.config$)

      if [[ $(uname) == "Linux" ]]; then
        local trash_cmd="${pkgs.gtrash}/bin/gtrash put"
        local trash_empty_cmd="${pkgs.gtrash}/bin/gtrash rm -f"
      else
        local trash_cmd="trash -y"
        local trash_empty_cmd="trash -ey"
      fi

      if [[ $1 == '-e' ]]; then
        shift
        local EMPTY_NOW=1
      fi

      parse_args "''${@}"
      trash_files
      empty_trash
    }

    main "''${@}" || exit 1
  '';
in
stdenv.mkDerivation rec {
  name = "fuck";
  src = ./.;
  buildInputs = [ fuck ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${fuck}/bin/* $out/bin
  '';
}
