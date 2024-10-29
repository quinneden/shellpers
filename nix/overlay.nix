final: prev: {
  cfg = final.callPackage nix/cfg { inherit final; };
  commit = final.callPackage nix/commit { inherit final; };
  cop = final.callPackage nix/cop { inherit final; };
  darwin-switch = final.callPackage nix/darwin-switch { inherit final; };
  diskusage = final.callPackage nix/diskusage { inherit final; };
  fuck = final.callPackage nix/fuck { inherit final; };
  lsh = final.callPackage nix/lsh { inherit final; };
  mi = final.callPackage nix/mi { inherit final; };
  nish = final.callPackage nix/nish { inherit final; };
  nix-clean = final.callPackage nix/nix-clean { inherit final; };
  nix-switch = final.callPackage nix/nix-switch { inherit final; };
  nix-get-sha256 = final.callPackage nix/nix-get-sha256 { inherit final; };
  rm-result = final.callPackage nix/rm-result { inherit final; };
  sec = final.callPackage nix/sec { inherit final; };
  wipe-linux = final.callPackage nix/wipe-linux { inherit final; };
}
