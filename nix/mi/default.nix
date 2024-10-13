{
  pkgs,
  stdenv,
  ...
}: let
  mi = pkgs.writeShellScriptBin "mi" ''
    if [[ $(uname) == Linux ]]; then
      OS_RELEASE=$(cat /etc/os-release)
      if [[ $(grep '^ID' <<<$OS_RELEASE) =~ nixos ]]; then
        echo -ne '\e[6 q'; ${pkgs.micro}/bin/micro "$@"; echo -ne '\e[6 q'
      else
        ${pkgs.micro}/bin/micro "$@"
      fi
    else
      micro "$@"
    fi
  '';
in
  stdenv.mkDerivation rec {
    name = "mi";
    src = ./.;
    buildInputs = [mi];
    installPhase = ''
      mkdir -p $out/bin
      cp ${mi}/bin/* $out/bin
    '';
  }
#'\e[6 q'
