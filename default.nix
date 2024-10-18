{
  self,
  pkgs,
  stdenv,
  system,
  ...
}:
let
  cfg = pkgs.callPackage ./nix/cfg { inherit pkgs; };
  commit = pkgs.callPackage ./nix/commit { inherit pkgs; };
  cop = pkgs.callPackage ./nix/cop { inherit pkgs; };
  darwin-switch = pkgs.callPackage ./nix/darwin-switch { inherit pkgs; };
  diskusage = pkgs.callPackage ./nix/diskusage { inherit pkgs; };
  fuck = pkgs.callPackage ./nix/fuck { inherit pkgs; };
  lsh = pkgs.callPackage ./nix/lsh { inherit pkgs; };
  mi = pkgs.callPackage ./nix/mi { inherit pkgs; };
  nish = pkgs.callPackage ./nix/nish { inherit pkgs; };
  nix-clean = pkgs.callPackage ./nix/nix-clean { inherit pkgs; };
  nix-switch = pkgs.callPackage ./nix/nix-switch { inherit pkgs; };
  nix-get-sha256 = pkgs.callPackage ./nix/nix-get-sha256 { inherit pkgs; };
  rm-result = pkgs.callPackage ./nix/rm-result { inherit pkgs; };
  sec = pkgs.callPackage ./nix/sec { inherit pkgs; };
  wipe-linux = pkgs.callPackage ./nix/wipe-linux { inherit pkgs; };
in
stdenv.mkDerivation rec {
  name = "util-scripts";
  version = 0.1;
  src = ./.;
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${cfg}/bin/* $out/bin
    ln -s ${commit}/bin/* $out/bin
    ln -s ${cop}/bin/* $out/bin
    ln -s ${diskusage}/bin/* $out/bin
    ln -s ${darwin-switch}/bin/* $out/bin
    ln -s ${fuck}/bin/* $out/bin
    ln -s ${lsh}/bin/* $out/bin
    ln -s ${mi}/bin/* $out/bin
    ln -s ${nish}/bin/* $out/bin
    ln -s ${nix-clean}/bin/* $out/bin
    ln -s ${nix-get-sha256}/bin/* $out/bin
    ln -s ${nix-switch}/bin/* $out/bin
    ln -s ${rm-result}/bin/* $out/bin
    ln -s ${sec}/bin/* $out/bin
    ln -s ${wipe-linux}/bin/* $out/bin
  '';
}
