{
  stdenv,
  writeShellScript,
}:
let
  script = writeShellScript "nish" ''
    # Pre-allocate arrays for better performance
    extra_args=()
    pkgs=()

    # Process all command-line arguments
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --arg | --argstr)
          [[ $# -ge 3 ]] && extra_args+=("$1" "$2" "$3") && shift 3 || { echo "Error: $1 requires two arguments" >&2; exit 1; }
          ;;
        --expr | -E | --command | -c)
          [[ $# -ge 2 ]] && extra_args+=("$1" "$2") && shift 2 || { echo "Error: $1 requires an argument" >&2; exit 1; }
          ;;
        -*)
          extra_args+=("$1")
          shift
          ;;
        *)
          regex='^[[:alnum:](.|/)]+(:|#).+'
          if [[ $1 =~ $regex ]]; then
            pkgs+=("$1")
          else
            pkgs+=("nixpkgs#$1")
          fi
          shift
          ;;
      esac
    done

    # Execute nix shell with collected arguments
    name="nix-shell" nix shell "''${pkgs[@]}" "''${extra_args[@]}"
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
