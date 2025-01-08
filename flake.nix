{
  description = "Various shell script tools. Some opinionated.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nh.url = "github:viperml/nh";
  };

  outputs =
    {
      nixpkgs,
      self,
      ...
    }@inputs:
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
                overlay = [
                  self.overlays.default
                  inputs.nh.overlays.default
                ];
              }
            )
          );
    in
    {
      overlays = rec {
        nix-shell-scripts = import ./src/overlay.nix;
        default = nix-shell-scripts;
      };

      packages = forEachSystem (
        pkgs:
        let
          inherit (pkgs.stdenv) isDarwin;
        in
        {
          inherit (pkgs)
            alphabetize
            a2dl
            cfg
            clone
            colortable
            commit
            cop
            diskusage
            fuck
            mi
            nish
            nix-clean
            nixhash
            nixos-deploy
            readme
            rm-result
            swatch
            ;

          metapackage = pkgs.callPackage ./src/metapackage.nix { inherit self; };
        }
        // (
          if isDarwin then
            {
              inherit (pkgs)
                lsh
                darwin-switch
                sec
                wipe-linux
                ;
            }
          else
            {
              inherit (pkgs) nix-switch;
            }
        )
      );

      apps = forEachSystem (
        { pkgs, lib }:
        {
          cacheout =
            let
              cacheAllPkgs = pkgs.writeShellApplication {
                runtimeInputs = with pkgs; [
                  cachix
                  jq
                ];
                text = ''
                  for target in $(
                    nix flake show --json --all-systems \
                      | jq -r '"packages" as $top \
                      | .[$top] | to_entries[] \
                      | .key as $arch | .value \
                      | keys[] | "\($top).\($arch).\(.)"'
                  ); do
                    nix build --json ".#$target" \
                      | jq -r '.[].outputs \
                      | to_entries[].value' \
                      | cachix push quinneden
                  done                
                '';
              };
            in
            {
              type = "app";
              program = lib.getExe cacheAllPkgs;
            };
        }
      );

      formatter = forEachSystem (pkgs: pkgs.nixfmt-rfc-style);
    };

  nixConfig = {
    extra-substituters = [ "https://quinneden.cachix.org" ];
    extra-trusted-public-keys = [
      "quinneden.cachix.org-1:1iSAVU2R8SYzxTv3Qq8j6ssSPf0Hz+26gfgXkvlcbuA="
    ];
  };
}
