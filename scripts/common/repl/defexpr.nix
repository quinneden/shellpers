rec {
  nix-darwin = builtins.getFlake "flake:nix-darwin";
  nixpkgs = builtins.getFlake "flake:nixpkgs";
  pkgs = import nixpkgs { };
  lib = nixpkgs.lib;

  mkNixosSystem =
    {
      modules ? [ ],
      system ? "aarch64-linux",
    }:
    nixpkgs.lib.nixosSystem {
      inherit modules system;
    };

  mkDarwinSystem =
    {
      modules ? [ ],
      system ? "aarch64-darwin",
    }:
    nix-darwin.lib.darwinSystem {
      inherit modules system;
    };
}
