{
  lib,
  micro,
  stdenv,
  writeShellScript,
}:
let
  binPath = lib.makeBinPath [ micro ];

  script = writeShellScript "mi" (
    ''
      PATH="${binPath}:$PATH"
    ''
    + (
      if stdenv.isLinux then
        ''
          echo -ne '\e[6 q'; micro "$@"; echo -ne '\e[6 q'
        ''
      else
        ''
          micro "$@"
        ''
    )
  );
in
stdenv.mkDerivation rec {
  name = "mi";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
