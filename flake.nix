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
      forEachSystem = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
      ];
    in
    {
      overlays = rec {
        nix-shell-scripts = import ./nix/overlay.nix;
        default = nix-shell-scripts;
      };

      packages = forEachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlays.default
              inputs.nh.overlays.default
            ];
          };
        in
        {
          inherit (pkgs)
            alphabetize
            adl
            cfg
            clone
            colortable
            commit
            cop
            darwin-switch
            diskusage
            fuck
            lsh
            mi
            nish
            nix-clean
            nix-switch
            nixhash
            nixos-deploy
            readme
            rm-result
            sec
            swatch
            wipe-linux
            ;

          metapackage = pkgs.callPackage ./nix/metapackage.nix { inherit self; };
        }
      );

      apps = forEachSystem (system: {
        cashout =
          let
            inherit (nixpkgs.legacyPackages.${system})
              cachix
              jq
              lib
              writeShellScriptBin
              ;
          in
          {
            type = "app";
            program = lib.getExe (
              writeShellScriptBin "cashout" ''
                nix flake archive --json |
                  jq -r '.path,(.inputs|to_entries[].value.path)' |
                  cachix push quinneden
                for target in $(
                  nix flake show --json --all-systems | jq '
                  "packages" as $top |
                  .[$top] |
                  to_entries[] |
                  .key as $arch |
                  .value |
                  keys[] |
                  "\($top).\($arch).\(.)"
                  ' | tr -d '"'
                ); do
                  nix build --json ".#$target" "''${@:2}" |
                  	jq -r '.[].outputs | to_entries[].value' |
                  	cachix push quinneden
                done
              ''
            );
          };
      });

      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };

  nixConfig = {
    extra-substituters = [ "https://quinneden.cachix.org" ];
    extra-trusted-public-keys = [
      "quinneden.cachix.org-1:1iSAVU2R8SYzxTv3Qq8j6ssSPf0Hz+26gfgXkvlcbuA="
    ];
  };
}
