final: prev: {
  a2dl = final.callPackage ./a2dl/package.nix { };
  alphabetize = final.callPackage ./alphabetize/package.nix { };
  cfg = final.callPackage ./cfg/package.nix { };
  clone = final.callPackage ./clone/package.nix { };
  colortable = final.callPackage ./colortable/package.nix { };
  commit = final.callPackage ./commit/package.nix { };
  cop = final.callPackage ./cop/package.nix { };
  darwin-switch = final.callPackage ./darwin-switch/package.nix { };
  diskusage = final.callPackage ./diskusage/package.nix { };
  del = final.callPackage ./del/package.nix { };
  lsh = final.callPackage ./lsh/package.nix { };
  metapackage = final.callPackage ./metapackage.nix { };
  mi = final.callPackage ./mi/package.nix { };
  nish = final.callPackage ./nish/package.nix { };
  nix-clean = final.callPackage ./nix-clean/package.nix { };
  nix-switch = final.callPackage ./nix-switch/package.nix { };
  nixhash = final.callPackage ./nixhash/package.nix { };
  nixos-deploy = final.callPackage ./nixos-deploy/package.nix { };
  readme = final.callPackage ./readme/package.nix { };
  rm-result = final.callPackage ./rm-result/package.nix { };
  sec = final.callPackage ./sec/package.nix { };
  swatch = final.callPackage ./swatch/package.nix { };
  wipe-linux = final.callPackage ./wipe-linux/package.nix { };
}
