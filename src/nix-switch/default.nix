{
  pkgs,
  stdenv,
  ...
}:
let
  nix-switch = pkgs.writeShellScriptBin "nix-switch" ''
    FLAKE="$HOME/.dotfiles"
    HOSTNAME="$(hostname)"

    ${pkgs.nh}/bin/nh os switch "$@"
  '';
in
stdenv.mkDerivation rec {
  name = "nix-switch";
  src = ./.;
  buildInputs = [ nix-switch ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${nix-switch}/bin/* $out/bin
  '';
}
