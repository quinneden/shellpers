final: prev: {
  shellpers =
    prev.lib.packagesFromDirectoryRecursive {
      callPackage = prev.lib.callPackageWith final;
      directory = ./scripts/common;
    }
    // (
      if prev.stdenv.isDarwin then
        (prev.lib.packagesFromDirectoryRecursive {
          callPackage = prev.lib.callPackageWith final;
          directory = ./scripts/darwin;
        })
      else
        (prev.lib.packagesFromDirectoryRecursive {
          callPackage = prev.lib.callPackageWith final;
          directory = ./scripts/linux;
        })
    );
}
