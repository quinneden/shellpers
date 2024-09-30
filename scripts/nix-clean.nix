{pkgs, ...}:
pkgs.writeShellScriptBin "nix-clean" ''
  message_loop() {
    while [[ $BREAK == 0 ]]; do
      printf "\rCollecting garbage from nix store.  "; sleep 0.7
      printf "\rCollecting garbage from nix store.. "; sleep 0.8
      printf "\rCollecting garbage from nix store..."; sleep 0.9
      printf "\rCollecting garbage from nix store   "; sleep 0.6
    done
  }
  collect_garbage() {
    read -ra arr1 < <(nix-collect-garbage -d 2>/dev/null)
    read -ra arr2 < <(sudo nix-collect-garbage -d 2>/dev/null)
    read -r store_paths < <(awk "BEGIN {print ''${arr1[0]}+''${arr2[0]}; exit}")
    read -r mib_float < <(awk "BEGIN {print ''${arr1[4]}+''${arr2[4]}; exit}")
  }
  main() {
    local BREAK=0
    message_loop
    if collect_garbage; then
      local BREAK=1; sleep 0.3
      printf "\n$store_paths store paths deleted, $mib_float MiB saved.\n"
    else
      printf "error: garbage collection failed\n"; exit 1
    fi
  }
  main || exit 1
''
