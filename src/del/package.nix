{
  coreutils,
  lib,
  stdenv,
  trash-cli,
  writeScript,
  writeShellScript,
  installShellFiles,
}:
with lib;
let
  binPath = makeBinPath [
    coreutils
    trash-cli
  ];

  del = writeShellScript "del" ''
    PATH="${binPath}:$PATH"; export PATH

    parse_args() {
      for f in "''${@}"; do
        if [[ -L $f ]]; then
          abs_symlink=$(realpath -s $f)
          files+=("$abs_symlink")
        elif [[ ! -L $f && -e $f ]]; then
          abs_path=$(realpath -q $f)
          files+=("$abs_path")
        else
          echo "error: $f: path does not exist"
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
      owner=$(stat -c%u $f)

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
        (($trash_empty_cmd &>/dev/null) &)
      else
        ((sleep 180 && $trash_empty_cmd &>/dev/null) &)
      fi
    }

    main() {
      local files=()
      local PROTECT=($HOME/.dotfiles$ $HOME/workdir$ $HOME/repos$ $HOME/.config$)

      if [[ $(uname) == 'Linux' ]]; then
        local trash_cmd="trash-put -f"
        local trash_empty_cmd="trash-empty -f"
      else
        TRASHDIR="$HOME/.Trash"
        local trash_cmd="trash-put --trash-dir $TRASHDIR -f"
        local trash_empty_cmd="trash-empty --trash-dir $TRASHDIR -f"
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

  undel = writeShellScript "undel" ''
    PATH=${binPath}:$PATH; export PATH

    parse_args() {
      args=()
      restore=()
      if [[ $# -ge 1 ]]; then
        for i in "''${@}"; do args+=("$(basename $i)"); done
        for arg in "''${args[@]}"; do
          if [[ -f $TRASHDIR/info/$arg.trashinfo ]]; then
            orig_path=$(awk -F'='  '/Path/ {print $2}' < $TRASHDIR/info/$arg.trashinfo)
            restore+=("$orig_path")
          fi
        done
      fi
    }

    main() {
      if [[ $(uname) == 'Darwin' ]]; then
        TRASHDIR="$HOME/.Trash"
        trash_restore_cmd="trash-restore --trash-dir $HOME/.Trash"
      else
        trash_restore_cmd="trash-restore"
      fi

      parse_args "$@"

      for f in "''${restore[@]}"; do
        eval $trash_restore_cmd "$f" <<<'0' >/dev/null
      done
    }

    main "$@" || exit 1
  '';

  undelCompletion = writeScript "_undel" (
    if stdenv.isDarwin then
      ''
        #compdef undel udel

        _undel() {
          _files -W ~/.Trash/files/
        }

        if [ "$funcstack[1]" = "_undel" ]; then
            _undel "$@"
        else
            compdef _undel undel udel
        fi
      ''
    else
      ''
        #compdef undel udel

        _undel() {
          _files -W ~/.local/share/trash/files/
        }

        if [ "$funcstack[1]" = "_undel" ]; then
            _undel "$@"
        else
            compdef _undel undel udel
        fi
      ''
  );
in
stdenv.mkDerivation rec {
  name = "del";
  src = ./.;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    install -m 755 ${del} $out/bin/del
    install -m 755 ${undel} $out/bin/undel
    ln -s $out/bin/undel $out/bin/udel

    installShellCompletion --zsh ${undelCompletion}

    runHook postInstall
  '';
}
