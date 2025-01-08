{
  self,
  stdenv,
  ...
}:
let
  pkgNames = [
    "a2dl"
    "alphabetize"
    "cfg"
    "clone"
    "colortable"
    "commit"
    "cop"
    "darwin-switch"
    "diskusage"
    "fuck"
    "lsh"
    "mi"
    "nish"
    "nix-clean"
    "nix-switch"
    "nixhash"
    "nixos-deploy"
    "readme"
    "rm-result"
    "sec"
    "swatch"
    "wipe-linux"
  ];

  pkgExe = map (pkg: toString self.packages.aarch64-darwin.${pkg} + "/bin/${pkg}") pkgNames;
in
stdenv.mkDerivation {
  name = "metapackage";
  src = ./.;

  installPhase = ''
    mkdir -p $out/bin
    pkgExe=(${toString pkgExe})

    for exe in "''${pkgExe[@]}"; do
      install -m 755 $exe $out/bin
    done
  '';
}
