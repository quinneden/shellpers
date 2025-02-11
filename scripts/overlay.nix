final: prev: {
  nix-shell-scripts = prev.lib.packagesFromDirectoryRecursive {
    callPackage = prev.lib.callPackageWith final;
    directory = ./.;
  };
}
