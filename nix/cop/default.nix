{
  pkgs,
  stdenv,
  ...
}: let
  cop = pkgs.writeShellScriptBin "cop" ''
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
      command gh copilot "''${args[@]}"
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
    buildInputs = [cop];
    installPhase = ''
      mkdir -p $out/bin
      cp ${cop}/bin/* $out/bin
    '';
  }
