{ stdenv, writeShellScript }:
let
  script = writeShellScript "clone" ''
    if [[ $1 == */* && $1 != http* ]]; then
      owner=$(echo "$1" | cut -f 1 -d'/')
      repo=$(echo "$1" | cut -f 2 -d'/')
      if [[ $? -eq 2 ]]; then
        git clone https://github.com/"$owner"/"$repo" "$2"
      else
        git clone https://github.com/"$owner"/"$repo"
      fi
    elif [[ $1 == http* ]]; then
      url="$1"
      owner=$(echo $url | awk -F'/' '{print $(NF-1)}')
      repo=$(echo $url | awk -F'/' '{print $NF}' | sed 's/\.git//g')
      if [[ $? -eq 2 ]]; then
        git clone https://github.com/"$owner"/"$repo" "$repo"
      else
        git clone https://github.com/"$owner"/"$repo" "$2"
      fi
    fi
  '';
in
stdenv.mkDerivation rec {
  name = "clone";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
