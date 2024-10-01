#!/usr/bin/env bash

set -e

cd "$(dirname $0)"

result="$(readlink result)"

if [[ $# -eq 1 && -d $1 ]]; then
  prefix="$1"
else
  prefix="/usr/local/bin"
fi

if [[ -d $result ]]; then
  for i in "$result"/bin/*; do
    sudo cp "$i" "$prefix/$(basename $i)"
  done
else
  echo "error: nothing to install"
  exit 1
fi
