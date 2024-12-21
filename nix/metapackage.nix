{
  pkgs,
  self,
  stdenv,
  ...
}:
let
  packages = with self.packages.${pkgs.system}; [
    adl
    alphabetize
    cfg
    clone
    colortable
    commit
    cop
    darwin-switch
    diskusage
    fuck
    lsh
    mi
    nish
    nix-clean
    nix-switch
    nixhash
    nixos-deploy
    readme
    rm-result
    sec
    swatch
    wipe-linux
  ];
in
stdenv.mkDerivation rec {
  name = "metapackage";

  src = ./.;

  buildInputs = [ ] ++ packages;

  installPhase = ''
    mkdir -p $out/bin
    packages=(${toString packages})

    for pkg in "''${packages[@]}"; do
      cp $pkg/bin/* $out/bin
    done
  '';
}
