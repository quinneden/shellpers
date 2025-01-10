{ stdenv, writeShellScript }:
let
  inherit (stdenv) isDarwin;
  forSystem = if isDarwin then "darwin" else "nixos";

  script = writeShellScript "cfg" ''
    dotdir="$HOME/.dotfiles"
    pos="''${1:-}"
    system="${forSystem}"

    if [[ -z $pos ]]; then
      pat="flake.nix"
    elif [[ $pos =~ (nixos|darwin|home-manager)(/[[:alnum:]]+)? ]]; then
      pat="$pos"
    else
      pat="($system|home-manager)/(.+/)?$pos"
    fi

    mapfile -t files_matched < <(
      fd --regex "$pat" -e nix --full-path "$dotdir" |
      awk -F/ '{ print NF-1, $0 }' | sort -n | cut -d' ' -f2-
    )

    for file in "''${files_matched[@]}"; do
      relpath="''${file#$dotdir/}"
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
      micro "$chosen"
    else
      echo "No file selected."
    fi
  '';
in
stdenv.mkDerivation rec {
  name = "cfg";
  src = ./.;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
