{
  description = "Derivations for various shell scripts I use.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nh.url = "github:viperml/nh";
  };

  outputs =
    {
      nh,
      nixpkgs,
      self,
      ...
    }:
    let
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs
          [
            "aarch64-darwin"
            "aarch64-linux"
          ]
          (
            system:
            f ({
              pkgs = import nixpkgs {
                inherit system;
                overlays = [
                  self.overlays.default
                ] ++ (nixpkgs.lib.optional (system == "aarch64-darwin") nh.overlays.default);
              };
            })
          );
    in
    {
      overlays = rec {
        nix-shell-scripts = import ./overlay.nix;
        default = nix-shell-scripts;
      };

      packages = forEachSystem (
        { pkgs }:
        (pkgs.lib.packagesFromDirectoryRecursive {
          callPackage = pkgs.callPackage;
          directory = ./scripts;
        })
        // {
          metapackage =
            with pkgs;
            buildEnv {
              name = "nix-shell-scripts-metapackage";
              paths = lib.filter (x: (lib.isDerivation x) && (x.name != "metapackage")) (
                lib.attrValues nix-shell-scripts
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
                    ${lib.optionalString stdenv.isDarwin "nix build --show-trace --no-link --print-out-paths .#packages.aarch64-darwin.metapackage"}
                    nix build --show-trace --no-link --print-out-paths .#packages.aarch64-linux.metapackage
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
