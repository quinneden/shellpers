{
  pkgs,
  stdenv,
  ...
}:
let
  nix-switch = pkgs.writeShellScriptBin "nix-switch" ''
    sudo nixos-rebuild switch --flake $HOME/.dotfiles#nixos $@
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
