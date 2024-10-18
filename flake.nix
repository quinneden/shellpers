{
  description = "Flake outputs for binaries of various shell scripts.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = pkgs.callPackage ./default.nix { inherit self pkgs; };
          cfg = pkgs.callPackage nix/cfg { inherit pkgs; };
          commit = pkgs.callPackage nix/commit { inherit pkgs; };
          cop = pkgs.callPackage nix/cop { inherit pkgs; };
          darwin-switch = pkgs.callPackage nix/darwin-switch { inherit pkgs; };
          diskusage = pkgs.callPackage nix/diskusage { inherit pkgs; };
          fuck = pkgs.callPackage nix/fuck { inherit pkgs; };
          lsh = pkgs.callPackage nix/lsh { inherit pkgs; };
          mi = pkgs.callPackage nix/mi { inherit pkgs; };
          nish = pkgs.callPackage nix/nish { inherit pkgs; };
          nix-clean = pkgs.callPackage nix/nix-clean { inherit pkgs; };
          nix-switch = pkgs.callPackage nix/nix-switch { inherit pkgs; };
          nix-get-sha256 = pkgs.callPackage nix/nix-get-sha256 { inherit pkgs; };
          rm-result = pkgs.callPackage nix/rm-result { inherit pkgs; };
          sec = pkgs.callPackage nix/sec { inherit pkgs; };
          wipe-linux = pkgs.callPackage nix/wipe-linux { inherit pkgs; };
        };
        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
