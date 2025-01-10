{
  aria2,
  stdenv,
  writeShellScript,
}:
let
  script = writeShellScript "a2dl" ''
    URL="$1"
    if [[ "$URL" =~ ^http[s]*:// ]]; then
      output_dir="''${2:-$PWD}"
      aria2c "$URL" -d "$output_dir"
    else
      echo "error: malformed url"; exit 1
    fi
  '';
in
stdenv.mkDerivation rec {
  name = "a2dl";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [ aria2 ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
