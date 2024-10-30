final: prev: {
  nix-shell-scripts = final.callPackage ../default.nix { inherit final; };
  cfg = final.callPackage ./cfg { inherit final; };
  commit = final.callPackage ./commit { inherit final; };
  cop = final.callPackage ./cop { inherit final; };
  darwin-switch = final.callPackage ./darwin-switch { inherit final; };
  diskusage = final.callPackage ./diskusage { inherit final; };
  fuck = final.callPackage ./fuck { inherit final; };
  lsh = final.callPackage ./lsh { inherit final; };
  mi = final.callPackage ./mi { inherit final; };
  nish = final.callPackage ./nish { inherit final; };
  nix-clean = final.callPackage ./nix-clean { inherit final; };
  nix-switch = final.callPackage ./nix-switch { inherit final; };
  nix-get-sha256 = final.callPackage ./nix-get-sha256 { inherit final; };
  rm-result = final.callPackage ./rm-result { inherit final; };
  sec = final.callPackage ./sec { inherit final; };
  wipe-linux = final.callPackage ./wipe-linux { inherit final; };
}
