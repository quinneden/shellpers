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

  trashEmpty = "trash-empty -f" + (optionalString stdenv.isDarwin " --trash-dir ~/.Trash");
  trashPut = "trash-put -f" + (optionalString stdenv.isDarwin " --trash-dir ~/.Trash");
  trashRestore = "trash-restore" + (optionalString stdenv.isDarwin " --trash-dir ~/.Trash");
  trashDir = if stdenv.isDarwin then "~/.Trash" else "~/.local/share/trash";

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
            eval sudo ${trashPut} "$f"
          else
            eval ${trashPut} "$f"
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
        ((${trashEmpty} &>/dev/null) &)
      else
        ((sleep 300 && ${trashEmpty} &>/dev/null) &)
      fi
    }

    main() {
      local files=()
      local PROTECT=($HOME/.dotfiles$ $HOME/workdir$ $HOME/repos$ $HOME/.config$)

      while [[ $# -gt 0 ]]; do
        case "$1" in
          -e|--empty)
            EMPTY_NOW=1
            shift
            ;;
          -h|--help)
            echo "Usage: del [OPTIONS] [FILES]"
            echo "Options:"
            echo "  -e, --empty  Empty the trash immediately after deletion"
            echo "  -h, --help   Display this help message"
            exit 0
            ;;
          *)
            break
            ;;
        esac
      done

      parse_args "''${@}"
      trash_files
      empty_trash
    }

    main "''${@}" && exit 0
  '';

  undel = writeShellScript "undel" ''
    PATH=${binPath}:$PATH; export PATH

    parse_args() {
      args=()
      restore=()
      if [[ $# -ge 1 ]]; then
        for i in "''${@}"; do args+=("$(basename $i)"); done
        for arg in "''${args[@]}"; do
          if [[ -f ${trashDir}/info/$arg.trashinfo ]]; then
            orig_path=$(awk -F'='  '/Path/ {print $2}' < ${trashDir}/info/"$arg.trashinfo")
            restore+=("$orig_path")
          fi
        done
      fi
    }

    main() {
      parse_args "$@"

      for f in "''${restore[@]}"; do
        eval ${trashRestore} "$f" <<<'0' >/dev/null
      done
    }

    main "$@" && exit 0
  '';

  undelCompletion = writeScript "_undel" ''
    #compdef undel udel

    _undel() {
      _files -W ${trashDir}/files/
    }

    if [ "$funcstack[1]" = "_undel" ]; then
        _undel "$@"
    else
        compdef _undel undel udel
    fi
  '';
in

stdenv.mkDerivation {
  name = "del";
  src = ./.;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ${del} $out/bin/del
    install -Dm755 ${undel} $out/bin/undel

    pushd $out/bin >/dev/null
    ln -s undel udel
    popd >/dev/null

    installShellCompletion --zsh ${undelCompletion}

    runHook postInstall
  '';
}
