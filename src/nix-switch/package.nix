{ stdenv, writeShellScript }:
let
  script = writeShellScript "nix-switch" ''
    NH_FLAKE="$HOME/.dotfiles"
    nh os switch --hostname "macmini-m1" -- "$@"
  '';
in
stdenv.mkDerivation rec {
  name = "nix-switch";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
