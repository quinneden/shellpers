{
  micro,
  stdenv,
  writeShellScript,
}:
let
  script = writeShellScript "mi" (
    if stdenv.isLinux then
      ''
        echo -ne '\e[6 q'; micro "$@"; echo -ne '\e[6 q'
      ''
    else
      ''
        micro "$@"
      ''
  );
in
stdenv.mkDerivation rec {
  name = "mi";
  src = ./.;

  nativeBuildInputs = [ micro ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
