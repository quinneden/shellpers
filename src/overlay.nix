final: prev: {
  nix-shell-scripts = {
    a2dl = prev.callPackage ./a2dl/package.nix { };
    alphabetize = prev.callPackage ./alphabetize/package.nix { };
    cfg = prev.callPackage ./cfg/package.nix { };
    clone = prev.callPackage ./clone/package.nix { };
    colortable = prev.callPackage ./colortable/package.nix { };
    commit = prev.callPackage ./commit/package.nix { };
    cop = prev.callPackage ./cop/package.nix { };
    darwin-switch = prev.callPackage ./darwin-switch/package.nix { };
    diskusage = prev.callPackage ./diskusage/package.nix { };
    del = prev.callPackage ./del/package.nix { };
    lsh = prev.callPackage ./lsh/package.nix { };
    mi = prev.callPackage ./mi/package.nix { };
    nish = prev.callPackage ./nish/package.nix { };
    nix-clean = prev.callPackage ./nix-clean/package.nix { };
    nix-switch = prev.callPackage ./nix-switch/package.nix { };
    nixhash = prev.callPackage ./nixhash/package.nix { };
    nixos-deploy = prev.callPackage ./nixos-deploy/package.nix { };
    readme = prev.callPackage ./readme/package.nix { };
    rm-result = prev.callPackage ./rm-result/package.nix { };
    swatch = prev.callPackage ./swatch/package.nix { };
    wipe-linux = prev.callPackage ./wipe-linux/package.nix { };
  };
}
