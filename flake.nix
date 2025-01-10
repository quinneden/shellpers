{
  description = "Various shell script tools. Some opinionated.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, self }:
    let
      forEachSystem = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
      ];
    in
    {
      overlays = rec {
        nix-shell-scripts = import ./src/overlay.nix;
        default = nix-shell-scripts;
      };

      packages = forEachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          inherit (pkgs)
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
              paths = [
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
        }
      );

      apps = forEachSystem (
        system:
        let
          inherit (nixpkgs.legacyPackages.${system}) writeShellApplication cachix lib;
        in
        with lib;
        {
          cacheout = {
            type = "app";
            program = getExe (writeShellApplication {
              name = "cacheout";
              runtimeInputs = [ cachix ];
              text = ''
                cachix push quinneden < <(
                  nix build --no-link --print-out-paths .#packages.aarch64-darwin.metapackage
                  nix build --no-link --print-out-paths .#packages.aarch64-linux.metapackage
                )
              '';
            });
          };
        }
      );

      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };

  nixConfig = {
    extra-substituters = [ "https://quinneden.cachix.org" ];
    extra-trusted-public-keys = [
      "quinneden.cachix.org-1:1iSAVU2R8SYzxTv3Qq8j6ssSPf0Hz+26gfgXkvlcbuA="
    ];
  };
}
