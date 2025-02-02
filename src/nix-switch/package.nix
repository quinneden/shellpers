{
  lib,
  pkgs,
  stdenv,
  writeShellApplication,
}:
let
  script = writeShellApplication {
    name = "nix-switch";
    runtimeInputs = [ pkgs.nh ];
    text = ''
      NH_FLAKE="''${NH_FLAKE:-$HOME/.dotfiles}"
      REF=$(
        nix flake show --json "$NH_FLAKE" 2>/dev/null \
        | jq -r '.nixosConfigurations | to_entries | .[].key'
      )

      nh os switch --hostname "$REF" "$@"
    '';
  };
in

with lib;

stdenv.mkDerivation rec {
  name = "nix-switch";
  src = script;

  installPhase = ''
    runHook preInstall
    install -Dm 755 "bin/${name}" "$out/bin/${name}"
    runHook postInstall
  '';
}
