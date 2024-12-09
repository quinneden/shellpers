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
    read -ra arr1 < <(sudo nix-collect-garbage -d)
    read -ra arr2 < <(nix-collect-garbage -d)
    read -r store_paths < <(awk "BEGIN {print ''${arr1[0]}+''${arr2[0]}; exit}")
    read -r mib_float < <(awk "BEGIN {print ''${arr1[4]}+''${arr2[4]}; exit}")
    printf "$store_paths $mib_float"
  '';

  nix-clean = writeShellScriptBin "nix-clean" ''
    tmpfile="$(mktemp -p /tmp -t nix-clean)"

    /nix/store/2kh20kzsh8p9b045janwracxwh43zzcf-gum-0.14.5/bin/gum spin --show-output \
      --title.foreground=220 \
      --title="Collecting garbage..." \
      --spinner=line \
      --spinner.foreground=202 \
        ${collect-garbage} > "$tmpfile"

    store_paths="$(cut -f1 -d' ' < $tmpfile)"
    mib_float="$(cut -f2 -d' ' < $tmpfile)"

    rm "$tmpfile"

    if [[ $# -eq 0 ]]; then
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
