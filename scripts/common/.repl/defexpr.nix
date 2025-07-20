rec {
  nix-darwin = builtins.getFlake "flake:nix-darwin";
  home-manager = builtins.getFlake "flake:home-manager";

  pkgs = import <nixpkgs> { };
  lib = import <nixpkgs/lib>;

  mkNixosSystem =
    {
      modules ? [ { system.stateVersion = lib.versions.majorMinor lib.version; } ],
      system ? "aarch64-linux",
    }:
    lib.nixosSystem { inherit modules system; };

  mkDarwinSystem =
    {
      modules ? [ { system.stateVersion = 6; } ],
      system ? "aarch64-darwin",
    }:
    nix-darwin.lib.darwinSystem { inherit modules system; };

  darwinOptions = (mkDarwinSystem { }).options;
  nixosOptions = (mkNixosSystem { }).options;

  homeOptions =
    let
      homeConfig = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          {
            home.username = "quinn";
            home.homeDirectory = "${if pkgs.stdenv.isDarwin then "/Users" else "/home"}/quinn";
            home.stateVersion = lib.versions.majorMinor lib.version;
          }
        ];
      };
    in
    homeConfig.options;

  getFlake' = p: builtins.getFlake (builtins.toPath p);
}
