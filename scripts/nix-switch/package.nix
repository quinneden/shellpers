{
  jq,
  lib,
  nh,
  stdenv,
  writeShellScript,
}:
let
  binPath = lib.makeBinPath [
    jq
    nh
  ];

  script = writeShellScript "nix-switch" ''
    PATH="${binPath}:$PATH"

    NH_FLAKE="''${NH_FLAKE:-$HOME/.dotfiles}"
    REF=$(
      nix flake show --json "$NH_FLAKE" 2>/dev/null \
      | jq -r '.nixosConfigurations | to_entries | .[].key'
    )

    nh os switch --hostname "$REF" "$NH_FLAKE" -- "$@"
  '';
in
stdenv.mkDerivation rec {
  name = "nix-switch";
  src = ./.;

  installPhase = ''
    runHook preInstall
    install -Dm 755 "${script}" "$out/bin/${name}"
    runHook postInstall
  '';
}
