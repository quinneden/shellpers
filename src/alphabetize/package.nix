{ stdenv, writeShellScript }:
let
  pasteCmd = if stdenv.isLinux then "wl-paste" else "pbpaste";

  script = writeShellScript "alphabetize" ''
    pb="$(${pasteCmd})"

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
stdenv.mkDerivation rec {
  name = "alphabetize";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
