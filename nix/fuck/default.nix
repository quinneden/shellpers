{
  lib,
  pkgs,
  stdenv,
  writeShellScriptBin,
  writeText,
  installShellFiles,
  ...
}:
let
  fuck = writeShellScriptBin "fuck" ''
    parse_args() {
      for f in "''${@}"; do
        if [[ -L $f ]]; then
          abs_symlink=$(${pkgs.coreutils}/bin/realpath -s $f)
          files+=("$abs_symlink")
        elif [[ ! -L $f && -e $f ]]; then
          abs_path=$(${pkgs.coreutils}/bin/realpath -q $f)
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
      owner=$(${pkgs.coreutils}/bin/stat -f "%u" $f)

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
        $trash_empty_cmd &>/dev/null
      else
        ((sleep 180 && $trash_empty_cmd &>/dev/null) &)
      fi
    }

    main() {
      local files=()
      local PROTECT=($HOME/.dotfiles$ $HOME/workdir$ $HOME/repos$ $HOME/.config$)

      if [[ $(uname) == 'Linux' ]]; then
        local trash_cmd="${pkgs.trash-cli}/bin/trash-put -f"
        local trash_empty_cmd="${pkgs.trash-cli}/bin/trash-empty -f"
      else
        TRASHDIR="$HOME/.Trash"
        local trash_cmd="${pkgs.trash-cli}/bin/trash-put --trash-dir $TRASHDIR -f"
        local trash_empty_cmd="${pkgs.trash-cli}/bin/trash-empty --trash-dir $TRASHDIR -f"
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

  unfuck = writeShellScriptBin "unfuck" ''
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
        trash_restore_cmd="${pkgs.trash-cli}/bin/trash-restore --trash-dir $HOME/.Trash"
      else
        trash_restore_cmd="${pkgs.trash-cli}/bin/trash-restore"
      fi

      parse_args "$@"

      for f in "''${restore[@]}"; do
        eval $trash_restore_cmd "$f" <<<'0' >/dev/null
      done
    }

    main "$@" || exit 1
  '';

  unfuckCompletion = writeText "_unfuck" (
    if stdenv.isDarwin then
      ''
        #compdef unfuck udel

        _unfuck() {
          _files -W ~/.Trash/files/
        }

        if [ "$funcstack[1]" = "_unfuck" ]; then
            _unfuck "$@"
        else
            compdef _unfuck unfuck udel
        fi
      ''
    else
      ''
        #compdef unfuck udel

        _unfuck() {
          _files -W ~/.local/share/trash/files/
        }

        if [ "$funcstack[1]" = "_unfuck" ]; then
            _unfuck "$@"
        else
            compdef _unfuck unfuck udel
        fi
      ''
  );

in
stdenv.mkDerivation rec {
  name = "fuck";

  src = ./.;

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    fuck
    unfuck
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${lib.getExe fuck} $out/bin
    cp ${lib.getExe fuck} $out/bin/del
    cp ${lib.getExe unfuck} $out/bin
    cp ${lib.getExe unfuck} $out/bin/udel
    ${postInstall}
  '';

  postInstall = ''
    installShellCompletion --zsh ${unfuckCompletion}
  '';
}
