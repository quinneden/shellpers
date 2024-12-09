{
  description = "Flake for my personal (opinionated) shell scripts.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      nixpkgs,
      self,
      ...
    }:
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
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          inherit (pkgs)
            cfg
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
            nixos-deploy
            readme
            rm-result
            sec
            wipe-linux
            ;
        }
      );

      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
