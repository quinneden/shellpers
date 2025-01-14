{
  description = "Various shell script tools. Some opinionated.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, self, ... }:
    let
      forEachSystem =
        function:
        nixpkgs.lib.genAttrs
          [
            "aarch64-darwin"
            "aarch64-linux"
          ]
          (
            system:
            function (
              import nixpkgs {
                inherit system;
                overlays = [ self.overlays.default ];
              }
            )
          );
    in
    {
      overlays = rec {
        nix-shell-scripts = import ./src/overlay.nix;
        default = nix-shell-scripts;
      };

      packages = forEachSystem (pkgs: {
        inherit (pkgs.nix-shell-scripts)
          a2dl
          alphabetize
          cfg
          clone
          colortable
          commit
          cop
          darwin-switch
          diskusage
          del
          lsh
          mi
          nish
          nix-clean
          nix-switch
          nixhash
          nixos-deploy
          readme
          rm-result
          swatch
          wipe-linux
          ;

        metapackage =
          with pkgs;
          buildEnv {
            name = "metapackage";
            paths = with nix-shell-scripts; [
              a2dl
              alphabetize
              cfg
              clone
              colortable
              commit
              cop
              darwin-switch
              diskusage
              del
              lsh
              mi
              nish
              nix-clean
              nix-switch
              nixhash
              nixos-deploy
              readme
              rm-result
              swatch
              wipe-linux
            ];
          };
      });

      apps = forEachSystem (pkgs: rec {
        default = cacheout;
        cacheout =
          let
            inherit (pkgs) writeShellApplication cachix lib;
            inherit (pkgs.stdenv) isDarwin;
          in
          with lib;
          {
            type = "app";
            program = getExe (writeShellApplication {
              name = "cacheout";
              runtimeInputs = [ cachix ];
              text = ''
                cachix push quinneden < <(
                  nix build --no-link --print-out-paths .#packages.nix-shell-scripts.aarch64-darwin.metapackage
                  ${optionalString isDarwin "nix build --no-link --print-out-paths .#packages.nix-shell-scripts.aarch64-darwin.metapackage"}
                )
              '';
            });
          };
      });

      formatter = forEachSystem (pkgs: pkgs.nixfmt-rfc-style);
    };

  nixConfig = {
    extra-substituters = [ "https://quinneden.cachix.org" ];
    extra-trusted-public-keys = [
      "quinneden.cachix.org-1:1iSAVU2R8SYzxTv3Qq8j6ssSPf0Hz+26gfgXkvlcbuA="
    ];
  };
}
