{
  description = "Derivations for various shell scripts I use.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh.url = "github:viperml/nh";
  };

  outputs =
    { nixpkgs, self, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      forEachSystem =
        f:
        lib.genAttrs
          [
            "aarch64-darwin"
            "aarch64-linux"
          ]
          (
            system:
            f {
              pkgs = import nixpkgs {
                inherit system;
                overlays = [
                  # inputs.lix-module.overlays.default
                  self.overlays.default
                ] ++ (lib.optional (system == "aarch64-darwin") inputs.nh.overlays.default);
              };
            }
          );
    in
    {
      overlays = rec {
        shellpers = import ./overlay.nix;
        default = shellpers;
      };

      packages = forEachSystem (
        { pkgs }:
        let
          platform = lib.elemAt (lib.splitString "-" pkgs.system) 1;
        in
        (pkgs.lib.packagesFromDirectoryRecursive {
          callPackage = pkgs.callPackage;
          directory = ./scripts/common;
        })
        // (pkgs.lib.packagesFromDirectoryRecursive {
          callPackage = pkgs.callPackage;
          directory = ./scripts/${platform};
        })
        // {
          metapackage =
            with pkgs;
            buildEnv {
              name = "shellpers-metapackage";
              paths = lib.filter (x: (lib.isDerivation x) && (x.name != "metapackage")) (
                lib.attrValues shellpers
              );
            };
        }
      );

      apps = forEachSystem (
        { pkgs }:
        rec {
          default = cacheout;

          cacheout =
            let
              inherit (pkgs)
                writeShellApplication
                lib
                stdenv
                ;
            in
            {
              type = "app";
              program = lib.getExe (writeShellApplication {
                name = "cacheout";
                runtimeInputs = [ pkgs.cachix ];
                text = ''
                  cachix push quinneden < <(
                    ${lib.optionalString stdenv.isDarwin "nix build --show-trace \
                      --no-link --print-out-paths .#packages.aarch64-darwin.metapackage"}
                    nix build --show-trace --no-link \
                      --print-out-paths .#packages.aarch64-linux.metapackage
                  )
                '';
              });
            };
        }
      );

      formatter = forEachSystem ({ pkgs }: pkgs.nixfmt-rfc-style);
    };

  nixConfig = {
    extra-substituters = [ "https://quinneden.cachix.org" ];
    extra-trusted-public-keys = [
      "quinneden.cachix.org-1:1iSAVU2R8SYzxTv3Qq8j6ssSPf0Hz+26gfgXkvlcbuA="
    ];
  };
}
