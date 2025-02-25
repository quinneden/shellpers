{
  lib,
  nh,
  stdenv,
  writeShellScript,
}:
let
  binPath = lib.makeBinPath [ nh ];

  script = writeShellScript "darwin-switch" ''
    PATH=${binPath}:$PATH

    if [[ ! -d $HOME/.dotfiles ]]; then
      echo "error: $HOME/.dotfiles: directory not found" >&2
      exit 1
    fi

    nh darwin switch -- "$@"
  '';
in
stdenv.mkDerivation rec {
  name = "darwin-switch";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
