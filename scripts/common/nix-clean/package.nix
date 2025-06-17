{
  coreutils,
  lib,
  jq,
  nh,
  stdenv,
  writeShellScript,
}:
let
  inherit (import ../../../lib) colors;

  binPath = lib.makeBinPath (
    [ nh ] ++ lib.optional stdenv.isDarwin jq ++ lib.optional stdenv.isLinux coreutils
  );

  script = writeShellScript "nix-clean" ''
    PATH=${binPath}:$PATH

    flags=()
    optimise=false

    ${
      if stdenv.isDarwin then
        ''
          get_size() {
            diskutil list -plist virtual |
            plutil -convert json -o - - |
            jq '
              .AllDisksAndPartitions
              | .[]
              | select(.DeviceIdentifier == "disk3")
              | .APFSVolumes[]
              | select(.MountPoint == "/nix")
              | .CapacityInUse
            ' | numfmt --to iec-i
          }
        ''
      else
        ''
          get_size() {
            df -h --output=used /nix | tail -n1 | xargs
          }
        ''
    }

    while [[ $? -gt 0 ]]; do
      case "$1" in
        -O | --optimise | --optimize)
          optimise=true
          shift
          ;;
        *)
          flags+=("$1")
          shift
      esac
    done

    (nh clean all ''${flags[@]} &>/dev/null) &
    pid=$!

    trap 'kill $pid' INT TERM

    while kill -0 "$pid" 2>/dev/null; do
      current_size=$(get_size)
      echo -ne "Cleaning.   (current size: ${colors.YELLOW}$current_size${colors.RESET})\r"; sleep 0.5
      echo -ne "Cleaning..  (current size: ${colors.YELLOW}$current_size${colors.RESET})\r"; sleep 0.5
      echo -ne "Cleaning... (current size: ${colors.YELLOW}$current_size${colors.RESET})\r"; sleep 0.7
      echo -ne "Cleaning    (current size: ${colors.YELLOW}$current_size${colors.RESET})\r"; sleep 0.3
    done && echo -e "\n${colors.GREEN}Done!${colors.RESET}"

    if $optimise; then
      nix store optimise
    fi
  '';
in
stdenv.mkDerivation rec {
  name = "nix-clean";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
