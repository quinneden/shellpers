{
  description = "Flake for my personal (opinionated) shell scripts.";

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
        "x86_64-linux"
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
            inherit system inputs;
            overlays = [
              self.overlays.default
              inputs.nh.overlays.default
            ];
          };
        in
        {
          inherit (pkgs)
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
            nix-get-sha256
            nix-switch
            nixhash
            nixos-deploy
            readme
            rm-result
            sec
            swatch
            wipe-linux
            ;
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
