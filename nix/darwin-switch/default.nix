{
  pkgs,
  stdenv,
  ...
}: let
  darwin-switch = pkgs.writeShellScriptBin "darwin-switch" ''
    /run/current-system/sw/bin/darwin-rebuild switch --flake $HOME/.dotfiles#macos "$@"
  '';
in
  stdenv.mkDerivation rec {
    name = "darwin-switch";
    src = ./.;
    buildInputs = [darwin-switch];
    installPhase = ''
      mkdir -p $out/bin
      cp ${darwin-switch}/bin/* $out/bin
    '';
  }

