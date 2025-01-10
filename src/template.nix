{
  stdenv,
  writeShellScript,
}:
let
  script = writeShellScript "" '''';
in
stdenv.mkDerivation {
  name = "";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin
    runHook postInstall
  '';
}
