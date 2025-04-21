{ stdenv, writeShellScript }:
let
  script = writeShellScript "nish" ''
    extra_args=()
    pkgs=()
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --arg | --argstr)
          extra_args+=("$1" "$2" "$3")
          shift 3
          ;;
        --expr | -E | --command | -c)
          extra_args+=("$1" "$2")
          shift 2
          ;;
        -*)
          extra_args+=("$1")
          shift
          ;;
        *)
          if [[ $1 =~ ^[[:alnum:].]+[:|#].+ ]]; then
            pkgs+=("$1")
          else
            pkgs+=("nixpkgs#$1")
          fi
          shift
          ;;
      esac
    done

    IN_NIX_SHELL=true name="nix-shell" nix shell ''${pkgs[@]} ''${extra_args[@]}
  '';
in
stdenv.mkDerivation rec {
  name = "nish";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
