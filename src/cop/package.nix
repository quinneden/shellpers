{
  gh,
  stdenv,
  writeShellScript,
}:
let
  script = writeShellScript "cop" ''
    parse_args() {
      if [[ $# -eq 0 ]]; then
        args=("--help"); export args
      elif [[ $1 -eq 'help' ]]; then
        shift
        for arg in "''${@}"; do
          args+=("$arg")
        done
        args+=("--help")
        export args
      else
        for arg in "''${@}"; do
          args+=("$arg")
        done
        export args
      fi
    }

    gh_copilot() {
      gh copilot "''${args[@]}"
    }

    main() {
      parse_args "''${@}"
      gh_copilot "''${args[@]}"
    }

    main "''${@}"; exit
  '';
in
stdenv.mkDerivation rec {
  name = "cop";
  src = ./.;

  nativeBuildInputs = [ gh ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
