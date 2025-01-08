{
  pkgs,
  stdenv,
  ...
}:
let
  nish = pkgs.writeShellScriptBin "nish" ''
    parse_args() {
      if [[ $# -ge 1 ]]; then
        if [[ $1 =~ -.$ ]]; then
          for p in "''${@:2}"; do
            pkgs+=("nixpkgs#$p")
          done
        else
          if [[ $1 =~ ^.+#.+$ ]] || [[ $1 =~ ^github:.+$ ]]; then
            pkgs="$1"
          else
            for p in "''${@}"; do
              pkgs+=("nixpkgs#$p")
            done
          fi
        fi
        export pkgs
      fi
    }

    nix_shell() {
      if [[ $# -ge 1 ]]; then
        case $1 in
          -d)
            nix develop -c zsh
            return;;
          -p)
            nix-shell -p "''${@:2}" --run zsh
            return;;
          .)
            nix shell;;
          *)
            nix shell "''${pkgs[@]}"
        esac
      else
        if [[ -f ./flake.nix || -f ../flake.nix ]]; then
          nix shell
        else
          nix shell nixpkgs#stdenv
        fi
      fi
    }

    nish_command() {
      pkgs=()
      parse_args "$@"
      nix_shell "$@"
    }

    nish_command "$@"; exit
  '';
in
stdenv.mkDerivation {
  name = "nish";
  src = ./.;
  buildInputs = [ nish ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${nish}/bin/* $out/bin
  '';
}
