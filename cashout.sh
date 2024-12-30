#!/usr/bin/env bash

set -xe

nix flake archive --json |
  jq -r '.path,(.inputs|to_entries[].value.path)' |
  cachix push "$cache"
for target in $(
  nix flake show --json --all-systems | jq -r '
  ["checks", "packages", "devShells"] as $tops
  | $tops[] as $top
  | .[$top]
  | to_entries[]
  | .key as $arch
  | .value
  | keys[]
  | "\($top).\($arch).\(.)"'
); do
  nix build --json ".#$target" "${@:2}" |
  	jq -r '.[].outputs | to_entries[].value' |
  	cachix push "$cache"
done
