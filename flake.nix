{
  description = "Flake outputs for binaries of various shell scripts.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          default = pkgs.callPackage ./default.nix {inherit self;};
          cfg = pkgs.callPackage nix/cfg.nix {inherit pkgs;};
          cop = pkgs.callPackage nix/cop.nix {inherit pkgs;};
          diskusage = pkgs.callPackage nix/diskusage.nix {inherit pkgs;};
          fuck = pkgs.callPackage nix/fuck.nix {inherit pkgs;};
          mi = pkgs.callPackage nix/mi.nix {inherit pkgs;};
          nish = pkgs.callPackage nix/nish.nix {inherit pkgs;};
          nix-clean = pkgs.callPackage nix/nix-clean.nix {inherit pkgs;};
          nix-get-sha256 = pkgs.callPackage nix/nix-get-sha256.nix {inherit pkgs;};
          rm-result = pkgs.callPackage nix/rm-result.nix {inherit pkgs;};
          sec = pkgs.callPackage nix/sec.nix {inherit pkgs;};
        };
      }
    );
}
