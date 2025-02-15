{
  lib,
  ncdu,
  stdenv,
  writeShellScript,
}:
let
  binPath = lib.makeBinPath [ ncdu ];

  script = writeShellScript "diskusage" ''
    PATH="${binPath}:$PATH"

    ncdu_root() {
      test_file=$(ncdu -f /tmp/ncdu_root.json -o- &>/dev/null && echo OK)
      if [[ -e /tmp/ncdu_root.json ]]; then
        if [[ $test_file != 'OK' ]]; then
          sudo rm -rf /tmp/ncdu_root.json && ncdu_root.json
        else
          sudo ncdu -0 --enable-delete -f /tmp/ncdu_root.json
        fi
      else
        sudo ncdu -t8 --si -1x -o- / | sudo tee /tmp/ncdu_root.json | sudo ncdu -f- --enable-delete
      fi
    }

    ncdu_home() {
      test_file=$(ncdu -f /tmp/ncdu_home.json -o- &>/dev/null && echo OK)
      if [[ -e /tmp/ncdu_home.json ]]; then
        if [[ $test_file != 'OK' ]]; then
          rm -rf /tmp/ncdu_home.json && ncdu_home.json
        else
          ncdu -0 -f /tmp/ncdu_home.json
        fi
      else
        ncdu -t8 --si -1x -o- ~ | tee /tmp/ncdu_home.json | ncdu -f-
      fi
    }

    ncdu_cwd() {
      test_file=$(ncdu -f /tmp/ncdu_cwd.json -o- &>/dev/null && echo OK)
      if [[ $(pwd) == '/' ]]; then
        ncdu_root.json
      elif [[ $(pwd) == ~ ]]; then
        ncdu_home.json
      elif [[ -e /tmp/ncdu_cwd.json ]]; then
        if [[  $test_file != 'OK' ]]; then
          rm -rf /tmp/ncdu_cwd.json && ncdu_cwd.json
        else
          ncdu -0 -f /tmp/ncdu_cwd.json
        fi
      else
        ncdu -t8 --si -1x -o- "$(pwd)" | tee /tmp/ncdu_cwd.json | ncdu -f-
      fi
    }

    ncdu_pwd() {
      if [[ -n $1 ]]; then
        ncdu -t8 --si -1x "$1"
      else
        ncdu -t8 --si -1x "$(pwd)"
      fi
    }

    show_help() {
      cat <<EOF
    usage: diskusage <options>

    options:
      --help        show this message
      -r            scan root directory
      -h            scan home directory
    EOF
    }

    main() {
      case "$1" in
        '-r')
          ncdu_root;;
        '-h')
          ncdu_home;;
        '--help')
          show_help;;
        *)
          ncdu_pwd "$@";;
      esac
    }

    main "$@" || exit 1
  '';
in
stdenv.mkDerivation rec {
  name = "diskusage";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
