{ pkgs }:
with pkgs;
buildEnv {
  name = "metapackage";
  paths = [
    a2dl
    alphabetize
    cfg
    clone
    colortable
    commit
    cop
    darwin-switch
    diskusage
    del
    lsh
    mi
    nish
    nix-clean
    nix-switch
    nixhash
    nixos-deploy
    readme
    rm-result
    swatch
    wipe-linux
  ];
}

# stdenv.mkDerivation rec {
#   name = "metapackage";
#   src = allPackages;

#   installPhase = ''
#     runHook preInstall
#     mkdir -p $out/bin

#     echo "src: $src" >> $out/info

#     # install -m 755 $pkg $out

#     runHook postInstall
#   '';
# }
