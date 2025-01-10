{
  nixos-rebuild,
  stdenv,
  writeShellScript,
}:
let
  script = writeShellScript "nixos-deploy" ''
    if [[ $# -eq 2 ]]; then
      flakeref="$1"
      target="$2"
    else
      echo 'error: must provide flakeref and target host'; exit 1
    fi

    [[ $target =~ 'root' ]] || IF_NOT_ROOT="--use-remote-sudo"

    nixos-rebuild switch --fast --show-trace --flake "$flakeref" --target-host "$target" $IF_NOT_ROOT
  '';
in
stdenv.mkDerivation rec {
  name = "nixos-deploy";
  src = ./.;

  nativeBuildInputs = [ nixos-rebuild ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
