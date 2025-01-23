{
  nh,
  stdenv,
  writeShellScript,
}:
let
  script = writeShellScript "darwin-switch" ''
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

  buildInputs = [ nh ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
