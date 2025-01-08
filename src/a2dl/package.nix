{
  pkgs,
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
stdenv.mkDerivation {
  pname = "a2dl";
  src = ./.;

  nativeBuildInputs = [ pkgs.aria2 ];

  installPhase = ''
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin
  '';
}
