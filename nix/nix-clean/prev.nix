{
  lib,
  pkgs,
  stdenv,
  writeShellScript,
  writeShellScriptBin,
  ...
}:
let
  collect-garbage = writeShellScript "collect-garbage" ''
    DELETE_OLD="''${DELETE_OLD:-false}"
    DAYS="''${DAYS:-}"

    if $DELETE_OLD; then
      if [[ -n $DAYS ]]; then
        opts=("--delete-older-than" "$DAYS")
      else
        opts=("-d")
      fi
    fi

    read -ra arr1 < <(sudo nix-collect-garbage ''${opts[@]})
    read -ra arr2 < <(nix-collect-garbage ''${opts[@]})
    read -r store_paths < <(awk "BEGIN {print ''${arr1[0]}+''${arr2[0]}; exit}")
    read -r mib_float < <(awk "BEGIN {print ''${arr1[4]}+''${arr2[4]}; exit}")
    printf "%s" "$store_paths $mib_float"
  '';

  nix-clean = writeShellScriptBin "nix-clean" ''
    tmpfile="$(mktemp -p /tmp -t nix-clean)"

    trap 'rm $tmpfile; unset DELETE_OLD DAYS' EXIT

    case "$1" in
      -d|--delete-old) DELETE_OLD=true; export DELETE_OLD;;
      --delete-older-than) DELETE_OLD=true; DAYS="$2"; export DELETE_OLD DAYS;;
    esac

    ${lib.getExe pkgs.gum} spin --show-output \
      --title.foreground=220 \
      --title="Collecting garbage..." \
      --spinner=line \
      --spinner.foreground=202 \
      ${collect-garbage} > "$tmpfile" || exit 1

    store_paths="$(cut -f1 -d' ' < $tmpfile)"
    mib_float="$(cut -f2 -d' ' < $tmpfile)"

    if [[ -n $store_paths && -n $mib_float ]]; then
      printf "\n$store_paths store paths deleted, $mib_float MiB saved.\n"
    else
      printf "\nerror: garbage collection failed\n"; exit 1
    fi
  '';
in
stdenv.mkDerivation rec {
  name = "nix-clean";
  src = ./.;
  buildInputs = [ nix-clean ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${lib.getExe nix-clean} $out/bin
  '';
}
