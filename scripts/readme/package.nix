{
  glow,
  lib,
  stdenv,
  writeShellScript,
}:
let
  binPath = lib.makeBinPath [ glow ];

  script = writeShellScript "readme" ''
    PATH=${binPath}:$PATH

    if [[ -n $1 ]]; then
      readme="$1"
    else
      if git status &>/dev/null; then
        toplevel=$(git rev-parse --show-toplevel)
        mapfile -t readme < <(
          fd -i "README" $toplevel \
          | awk -F/ '{ print NF-1, $0 }' \
          | sort -n | cut -d' ' -f2-
        )
      else
        mapfile -t readme < <(
          fd -i "README" --max-depth 1 . \
          || fd -i "README" --max-depth 1 .. \
          | awk -F/ '{ print NF-1, $0 }' \
          | sort -n | cut -d' ' -f2-
        )
      fi
    fi

    if [[ ''${#readme[@]} -lt 1 ]]; then
      echo "error: no files found"
      exit 1
    elif [[ ''${#readme[@]} -gt 1 ]]; then
      for file in "''${readme[@]}"; do
        relpath="''${file#''${toplevel:-$PWD}/}"
        color="\033[96m"
        reset="\033[0m"

        while true; do
          printf "Open ''${color}''${relpath}''${reset}? (Y/n)"
          read -r -n 1 REPLY
          case $REPLY in
            [yY]|"")
              chosen="$file"
              break 2
              ;;
            [nN])
              echo -ne "\r\033[K"
              break
              ;;
            *)
              echo -ne "\r\033[K"
              ;;
          esac
        done
      done

      if [[ -n $chosen ]]; then
        glow "$chosen"
      else
        echo "No file selected."
      fi
    else
      glow "$readme"
    fi
  '';
in
stdenv.mkDerivation rec {
  name = "readme";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
