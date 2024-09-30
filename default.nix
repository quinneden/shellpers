{self, pkgs, stdenv, ...}: let
  cfg = pkgs.callPackage scripts/cfg.nix {};
  cop = pkgs.callPackage scripts/cop.nix {};
  diskusage = pkgs.callPackage scripts/diskusage.nix {};
  fuck = pkgs.callPackage scripts/fuck.nix {};
  mi = pkgs.callPackage scripts/mi.nix {};
  nish = pkgs.callPackage scripts/nish.nix {};
  nix-clean = pkgs.callPackage scripts/nix-clean.nix {};
  nix-get-sha256 = pkgs.callPackage scripts/nix-get-sha256.nix {};
  rm-result = pkgs.callPackage scripts/rm-result.nix {};
  sec = pkgs.callPackage scripts/sec.nix {};
in
stdenv.mkDerivation rec {
  name = "allScripts";
  src = ./scripts;
  buildInputs = [cfg cop diskusage fuck mi nish nix-clean nix-get-sha256 rm-result sec];
  installPhase = ''
    mkdir $out
    cp ${cfg}/bin/* $out
    cp ${cop}/bin/* $out
    cp ${diskusage}/bin/* $out
    cp ${fuck}/bin/* $out
    cp ${mi}/bin/* $out
    cp ${nish}/bin/* $out
    cp ${nix-clean}/bin/* $out
    cp ${nix-get-sha256}/bin/* $out
    cp ${rm-result}/bin/* $out
    cp ${sec}/bin/* $out
  '';
}
