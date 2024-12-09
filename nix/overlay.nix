final: prev: {
  cfg = final.callPackage ./cfg { };
  commit = final.callPackage ./commit { };
  cop = final.callPackage ./cop { };
  darwin-switch = final.callPackage ./darwin-switch { };
  diskusage = final.callPackage ./diskusage { };
  fuck = final.callPackage ./fuck { };
  lsh = final.callPackage ./lsh { };
  mi = final.callPackage ./mi { };
  nish = final.callPackage ./nish { };
  nix-clean = final.callPackage ./nix-clean { };
  nix-switch = final.callPackage ./nix-switch { };
  nix-get-sha256 = final.callPackage ./nix-get-sha256 { };
  nixos-deploy = final.callPackage ./nixos-deploy { };
  readme = final.callPackage ./readme { };
  rm-result = final.callPackage ./rm-result { };
  sec = final.callPackage ./sec { };
  wipe-linux = final.callPackage ./wipe-linux { };
}
