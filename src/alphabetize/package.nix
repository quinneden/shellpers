{
  lib,
  pkgs,
  stdenv,
  writeShellScriptBin,
  ...
}:
let
  paste = if stdenv.isLinux then "${pkgs.wl-clipboard}/bin/wl-paste" else "pbpaste";
  alphabetize = writeShellScriptBin "alphabetize" ''
    pb="$(${paste})"

    if [[ $1 == '-n' ]] || [[ -z $pb ]]; then
      while read -r line; do
        [[ -z $line ]] && break
        list+=("$line")
        formatted_list="$(printf '%s\n' "''${list[@]}" | tr -s ' ' | sed 's/^ //g')"
      done
    fi

    input="''${pb:-$formatted_list}"

    printf '%s' "$input" | sort
  '';
in
stdenv.mkDerivation {
  name = "alphabetize";
  src = ./.;

  buildInputs = [
    alphabetize
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${lib.getExe alphabetize} $out/bin
  '';
}
