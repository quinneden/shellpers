{
  jq,
  lib,
  nh,
  writeShellScriptBin,
}:

let
  binPath = lib.makeBinPath [
    jq
    nh
  ];
in

writeShellScriptBin "nix-switch" ''
  PATH="${binPath}:$PATH"

  NH_FLAKE="''${NH_FLAKE:-$HOME/.dotfiles}"
  REF=$(
    nix flake show --json "$NH_FLAKE" 2>/dev/null \
    | jq -r '.nixosConfigurations | to_entries | .[].key'
  )

  nh os switch --hostname "$REF" "$NH_FLAKE" -- "$@"
''
