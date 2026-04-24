{
  description = "Derivations for various shell scripts I use";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nh.url = "github:viperml/nh";
  };

  outputs =
    {
      nh,
      nixpkgs,
      self,
    }:
    let
      inherit (nixpkgs) lib;

      forEachSystem =
        f:
        lib.genAttrs [ "aarch64-darwin" "aarch64-linux" ] (
          system:
          f (
            import nixpkgs {
              inherit system;
              overlays = [
                nh.overlays.default
                self.overlays.default
              ];
            }
          )
        );
    in
    {
      overlays = {
        default = self.overlays.shellpers;
        shellpers = import ./overlay.nix;
      };

      packages = forEachSystem (
        pkgs:
        let
          platform = lib.elemAt (lib.splitString "-" pkgs.stdenv.hostPlatform.system) 1;
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

      apps = forEachSystem (pkgs: {
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.cacheout;

        cacheout = {
          type = "app";
          program = lib.getExe (
            pkgs.writeShellApplication {
              name = "cacheout";
              runtimeInputs = [ pkgs.cachix ];
              text = ''
                cachix push quinneden < <(
                  ${lib.optionalString pkgs.stdenv.isDarwin ''
                    nix build --show-trace --no-link --print-out-paths .#packages.aarch64-darwin.metapackage
                  ''}
                  nix build --show-trace --no-link --print-out-paths .#packages.aarch64-linux.metapackage
                )
              '';
            }
          );
        };
      });

      formatter = forEachSystem (
        pkgs: pkgs.nixfmt-tree.override { settings.formatter.nixfmt.options = [ "--strict" ]; }
      );
    };

  nixConfig = {
    extra-substituters = [ "https://quinneden.cachix.org" ];
    extra-trusted-public-keys = [
      "quinneden.cachix.org-1:1iSAVU2R8SYzxTv3Qq8j6ssSPf0Hz+26gfgXkvlcbuA="
    ];
  };
}
