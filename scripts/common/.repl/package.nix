{
  lib,
  nix,
  stdenv,
  writeShellScript,
}:
let
  binPath = lib.makeBinPath [ nix ];

  script = writeShellScript "repl" ''
    PATH=${binPath}:$PATH

    has_arg() {
      [[ ("$1" == *=* && -n ''${1#*=}) || ( -n "$2" && "$2" != -*)  ]];
    }

    extract_arg() {
      echo "''${2:-''${1#*=}}"
    }

    flags=()

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -* | --*)
          if ! has_arg "$@"; then
            flags+=("$1")
            shift
          else
            arg=$(extract_arg "$@")
            flags+=("$1" "$arg")
            shift 2
          fi
          ;;
      esac
    done

    nix repl --file ${./defexpr.nix} "''${flags[@]}"
  '';
in
stdenv.mkDerivation rec {
  name = "repl";
  src = ./.;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
