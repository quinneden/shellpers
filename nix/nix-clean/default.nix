{
  lib,
  pkgs,
  stdenv,
  ...
}:
let
  collect-garbage = pkgs.writeShellScriptBin "collect-garbage" ''
    read -ra arr1 < <(nix-collect-garbage -d 2>/dev/null)
    read -ra arr2 < <(sudo nix-collect-garbage -d 2>/dev/null)
    read -r store_paths < <(awk "BEGIN {print ''${arr1[0]}+''${arr2[0]}; exit}")
    read -r mib_float < <(awk "BEGIN {print ''${arr1[4]}+''${arr2[4]}; exit}")
    export arr1 arr2 store_paths mib_float
  '';

  nix-clean = pkgs.writeShellScriptBin "nix-clean" ''
    collect_garbage() {
      read -ra arr1 < <(nix-collect-garbage -d 2>/dev/null)
      read -ra arr2 < <(sudo nix-collect-garbage -d 2>/dev/null)
      read -r store_paths < <(awk "BEGIN {print ''${arr1[0]}+''${arr2[0]}; exit}")
      read -r mib_float < <(awk "BEGIN {print ''${arr1[4]}+''${arr2[4]}; exit}")
    }

    ${pkgs.gum}/bin/gum spin --show-error \
      --title.foreground=220 \
      --title="Collecting garbage..." \
      --spinner=line \
      --spinner.foreground=202 \
      ${collect-garbage}/bin/collect-garbage

    if [[ $# -eq 0 ]]; then
      printf "\n$store_paths store paths deleted, $mib_float MiB saved.\n"
    else
      printf "error: garbage collection failed\n"; exit 1
    fi
  '';
in
stdenv.mkDerivation rec {
  name = "nix-clean";
  src = ./.;
  buildInputs = [ nix-clean ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${nix-clean}/bin/* $out/bin
  '';
}
