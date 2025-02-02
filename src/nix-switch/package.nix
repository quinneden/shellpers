{
  lib,
  nh,
  stdenv,
  writeShellApplication,
}:
let
  script = writeShellApplication {
    name = "nix-switch";
    runtimeInputs = [ nh ];
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
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${getExe script} $out/bin/${name}
    runHook postInstall
  '';
}
