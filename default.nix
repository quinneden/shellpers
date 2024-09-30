{
  self,
  pkgs,
  stdenv,
  system,
  ...
}: let
  cfg = pkgs.callPackage scripts/cfg.nix {};
  cop = pkgs.callPackage scripts/cop.nix {};
  diskusage = pkgs.callPackage scripts/diskusage.nix {};
  fuck = pkgs.callPackage scripts/fuck.nix {};
  nish = pkgs.callPackage scripts/nish.nix {};
  nix-clean = pkgs.callPackage scripts/nix-clean.nix {};
  nix-get-sha256 = pkgs.callPackage scripts/nix-get-sha256.nix {};
  rm-result = pkgs.callPackage scripts/rm-result.nix {};
  sec = pkgs.callPackage scripts/sec.nix {};
in
  stdenv.mkDerivation rec {
    name = "allScripts";
    src = ./scripts;
    buildInputs = [cfg cop diskusage fuck nish nix-clean nix-get-sha256 rm-result sec];
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${cfg}/bin/* $out/bin
      ln -s ${cop}/bin/* $out/bin
      ln -s ${diskusage}/bin/* $out/bin
      ln -s ${fuck}/bin/* $out/bin
      ln -s ${nish}/bin/* $out/bin
      ln -s ${nix-clean}/bin/* $out/bin
      ln -s ${nix-get-sha256}/bin/* $out/bin
      ln -s ${rm-result}/bin/* $out/bin
      ln -s ${sec}/bin/* $out/bin
    '';
  }
