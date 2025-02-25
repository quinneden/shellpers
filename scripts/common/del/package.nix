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

  # trashEmpty = "trash-empty -f" + (optionalString stdenv.isDarwin " --trash-dir=$HOME/.Trash");
  # trashPut = "trash-put -f" + (optionalString stdenv.isDarwin " --trash-dir=$HOME/.Trash");
  # trashRestore = "trash-restore" + (optionalString stdenv.isDarwin " --trash-dir=$HOME/.Trash");
  # trashDir = if stdenv.isDarwin then "$HOME/.Trash" else "$HOME/.local/share/trash";

  trashDir = "$HOME/.local/share/Trash";
  trashEmpty = "trash-empty -f";
  trashPut = "trash-put -f";
  trashRestore = "trash-restore";

  del = writeShellScript "del" ''
    PATH="${binPath}:$PATH"; export PATH

    ${optionalString stdenv.isDarwin ''
      if ! [[ -L ${trashDir}/files ]]; then
        rm -rf ${trashDir}
        mkdir -p ${trashDir}
        ln -s $HOME/.Trash ${trashDir}/files
      fi
    ''}

    files=()
    PROTECT=($HOME/.dotfiles$ $HOME/workdir$ $HOME/repos$ $HOME/.config$)
    EMPTY_NOW=false

    parse_arg() {
      if [[ -L $1 ]]; then
        abs_symlink=$(realpath -s $1)
        files+=("$abs_symlink")
      elif [[ ! -L $1 && -e $1 ]]; then
        abs_path=$(realpath -q $1)
        files+=("$abs_path")
      else
        echo "error: $1: path does not exist"
      fi
    }

    show_help() {
      echo "Usage: del [OPTIONS] [FILES]"
      echo "Options:"
      echo "  -e, --empty    Empty the trash immediately after trashing files"
      echo "  -h, --help     Show this help message"
    }

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -e|--empty)
          EMPTY_NOW=true
          shift
          ;;
        -h|--help)
          show_help
          exit 0
          ;;
        *)
          parse_arg "$1"
          shift
          ;;
      esac
    done

    for p in "''${PROTECT[@]}"; do
      for f in "''${files[@]}"; do
        if [[ $f =~ $p ]]; then
          echo "error: cannot delete protected file or directory: $1"
          files=("''${files[@]/$f}")
        fi
      done
    done

    if [[ -n $files ]]; then
      for f in "''${files[@]}"; do
        (${trashPut} "$f" || sudo ${trashPut} "$f") &>/dev/null
      done
    else
      exit 0
    fi

    echo "Deleted:"
    for f in "''${files[@]}"; do
      echo "    $(basename $f)"
    done

    if $EMPTY_NOW; then
      ((${trashEmpty} &>/dev/null) &)
    else
      ((sleep 300 && ${trashEmpty} &>/dev/null) &)
    fi
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
