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
          
        };
        apps = rec {
          hello = flake-utils.lib.mkApp {drv = self.packages.${system}.hello;};
          default = hello;
        };
      }
    );
}
