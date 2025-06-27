{
  coreutils,
  installShellFiles,
  lib,
  stdenv,
  trash-cli,
  writeShellScript,
  writeText,
}:

with lib;

let
  inherit (import ../../../lib) colors;

  binPath = makeBinPath [
    coreutils
    trash-cli
  ];

  trashDir = "$HOME/.local/share/Trash";
  trashEmpty = "trash-empty -f";
  trashPut = "trash-put -f";
  trashRestore = "trash-restore";

  del = writeShellScript "del" ''
    PATH="${binPath}:$PATH"; export PATH

    files=()
    protected_paths=($HOME/.dotfiles$ $HOME/Workdir$ $HOME/Repositories$ $HOME/.config$)
    empty_trash=false

    parse_arg() {
      if [[ -L $1 ]]; then
        abs_symlink=$(realpath -s $1)
        files+=("$abs_symlink")
      elif [[ -e $1 ]]; then
        abs_path=$(realpath -q $1)
        files+=("$abs_path")
      else
        echo "${colors.BOLD}${colors.RED}error:${colors.RESET} $1: path does not exist"
      fi
    }

    show_help() {
      echo "Usage: del [OPTIONS] [FILES]"
      echo "Options:"
      echo "    -e, --empty    Empty the trash"
      echo "    -h, --help     Show this help message"
    }

    ${optionalString stdenv.isDarwin ''
      if ! [[ -L ${trashDir}/files ]]; then
        rm -rf ${trashDir}
        mkdir -p ${trashDir}
        ln -s $HOME/.Trash ${trashDir}/files
      fi
    ''}

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -e | --empty)
          empty_trash=true
          shift
          ;;
        -h | --help)
          show_help
          exit 0
          ;;
        *)
          parse_arg "$1"
          shift
          ;;
      esac
    done

    for p in "''${protected_paths[@]}"; do
      for f in "''${files[@]}"; do
        if [[ $f =~ $p ]]; then
          echo "${colors.BOLD}${colors.RED}error:${colors.RESET} cannot delete protected file or directory: $f"
          files=("''${files[@]/$f}")
        fi
      done
    done

    if [[ -n $files ]]; then
      for f in "''${files[@]}"; do
        (${trashPut} "$f" || sudo ${trashPut} "$f") &>/dev/null
      done

      printf "Deleted:\n"
      printf "    %s\n" "''${files[@]}"
    fi

    if $empty_trash; then
      echo "${colors.RED}Empty trash?${colors.RESET} (y/N): "
      read -srN1 input
      case "$input" in
        [yY])
          sudo ${trashEmpty} && echo "Trash emptied!"
          ;;
        *)
          exit 0
          ;;
      esac
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

  undelCompletion = writeText "_undel" ''
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
