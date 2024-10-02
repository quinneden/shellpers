{
  pkgs,
  stdenv,
  ...
}: let
  mi = pkgs.writeShellScriptBin "mi" ''
    OS_RELEASE=$(cat /etc/os-release)

    if [[ $(grep '^ID' <<<$OS_RELEASE) =~ nixos ]]; then
      echo -ne '\e[6 q'
      ${pkgs.micro}/bin/micro "$@"
      echo -ne '\e[2 q'
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
