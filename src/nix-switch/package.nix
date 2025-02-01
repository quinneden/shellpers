{ stdenv, writeShellScript }:
let
  script = writeShellScript "nix-switch" ''
    nh os switch --hostname "nixos-macmini" -- "$@"
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
