{ stdenv, writeShellScript }:
let
  warnInfo = ''
    THIS SCRIPT IS DANGEROUS
    DO NOT BLINDLY RUN IT IF SOMEONE JUST SENT YOU HERE.
    IT WILL INDISCRIMINATELY WIPE A BUNCH OF PARTITIONS
    THAT MAY OR MAY NOT BE THE ONES YOU WANT TO WIPE.

    Press enter twice if you really want to continue.
    Press Control-C to exit.
  '';

  uuids = ''
    3D3287DE-280D-4619-AAAB-D97469CA9C71
    C8858560-55AC-400F-BBB9-C9220A8DAC0D
  '';

  script = writeShellScript "wipe-linux" ''
    set -e

    wipe() {
      diskutil list | grep Apple_APFS | grep '\b2\.5 GB' | sed 's/.* //g' | while read i; do
          diskutil apfs deleteContainer "$i"
      done
      diskutil list /dev/disk0 | grep -Ei 'asahi|linux|EFI' | sed 's/.* //g' | while read i; do
          diskutil eraseVolume free free "$i"
      done

      echo "${uuids}" > /tmp/uuids.txt

      diskutil apfs listVolumeGroups >> /tmp/uuids.txt

      cd /System/Volumes/iSCPreboot

      for i in ????????-????-????-????-????????????; do
        if grep -q "$i" /tmp/uuids.txt; then
          echo "KEEP $i"
        else
          echo "RM $i"
          sudo rm -rf "$i"
        fi
      done
    }

    main() {
      echo ${warnInfo}
      read -r
      read -r
      wipe
    }

    main && exit 0
  '';
in
stdenv.mkDerivation rec {
  name = "wipe-linux";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
