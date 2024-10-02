{pkgs, ...}: pkgs.writeShellScriptBin "commit" ''
  confirm() {
    while true; do
      read -sr -n 1 REPLY
      case $REPLY in
        [yY]) echo ; return 0 ;;
        [$'\x0A']) echo ; return 0 ;;
        [nN]) echo ; return 1 ;;
        *) printf " \033[31m %s \n\033[0m" "invalid input"
      esac
    done
  }

  REPONAME=$(basename $PWD | tr -d '.')
  TMPFILE=$(mktemp /tmp/git-commit-msg-$REPONAME.XXXXX)

  git status --porcelain | grep '^[MARCDT]' | sort
  | sed -re 's/^([[:upper:]])[[:upper:]]?[[:space:]]+/\\1:\\n/' \
  | awk '!x[$0]++' \
  | sed -re 's/^([[:upper:]]:)$/\\n\\1/' \
  | sed -re 's/^M:$/Modified: /' \
  | sed -re 's/^A:$/Added: /' \
  | sed -re 's/^R:$/Renamed: /' \
  | sed -re 's/^C:$/Copied: /' \
  | sed -re 's/^D:$/Deleted: /' \
  | sed -re 's/^T:$/File Type Changed: /' \
  | tr '\n' ' ' | xargs
  > $TMPFILE

  cat $TMPFILE

  confirm 'Commit with this message? [y\n]' || exit 1

  git commit -F $TMPFILE

  rm -f $TMPFILE
''
