{pkgs, ...}: pkgs.writeShellScriptBin "commit" ''
  git_status_json() {
    # Declare an associative array to store files by status
    declare -A status_files

    # Process each line of git status output
    while IFS= read -r line; do
        # Extract the status and the filename
        status="''${line:0:2}"  # First two characters are the status
        file="''${line:3}"      # Filename starts at the third character

        # Trim spaces from the status
        status=$(echo "$status" | xargs)

        # Append the file to the corresponding status list
        if [[ -n "''${status_files[$status]}" ]]; then
            status_files[$status]+=", \"$file\""
        else
            status_files[$status]="\"$file\""
        fi
    done <<< "$git_status"

    # Start the JSON output with a single object
    echo '{'
    echo '  "git_status": {'

    # Output the statuses and their file lists
    first_entry=true
    for status in "''${!status_files[@]}"; do
        # Set comma for subsequent entries
        if [ "$first_entry" = false ]; then
            echo ','
        fi
        first_entry=false

        # Output the status with the list of files
        echo "    \"$status\": [''${status_files[$status]}]"
    done

    # Close the JSON object
    echo '  }'
    echo '}'
  }

  parse_json() {
    modified=$(jq -r '.git_status | .M[]' < $tmp | tr '\n' ';' | sed s/';'/'\n  '/g)
    added=$(jq -r '.git_status | .A[]' < $tmp | tr '\n' ';' | sed s/';'/'\n  '/g)
    renamed=$(jq -r '.git_status | .R[]' < $tmp | tr '\n' ';' | sed s/';'/'\n  '/g)
    copied=$(jq -r '.git_status | .C[]' < $tmp | tr '\n' ';' | sed s/';'/'\n  '/g)
    deleted=$(jq -r '.git_status | .D[]' < $tmp | tr '\n' ';' | sed s/';'/'\n  '/g)
    ftchange=$(jq -r '.git_status | .T[]' < $tmp | tr '\n' ';' | sed s/';'/'\n  '/g)

    if [[ -n $added ]]; then
      cat >> $msg <<EOF
  Added:
    $added
  EOF
    fi

    if [[ -n $modified ]]; then
      cat >> $msg <<EOF
  Modified:
    $modified
  EOF
    fi

    if [[ -n $renamed ]]; then
      cat >> $msg <<EOF
  Renamed:
    $renamed
  EOF
    fi

    if [[ -n $copied ]]; then
      cat >> $msg <<EOF
  Copied:
    $copied
  EOF
    fi

    if [[ -n $deleted ]]; then
      cat >> $msg <<EOF
  Deleted:
    $deleted
  EOF
    fi

    if [[ -n $ftchange ]]; then
      cat >> $msg <<EOF
  Filetype changed:
    $ftchange
  EOF
    fi
  }

  confirm() {
    while true; do
      read -sr -n 1 -p 'Commit with this message? [y\n]' REPLY
      case $REPLY in
        [yY]) echo ; return 0 ;;
        [nN]) echo ; return 1 ;;
        *) printf " \033[31m %s \n\033[0m" "invalid input"
      esac
    done
  }

  main() {
    git_status=$(git status --porcelain --untracked-files=no)
    tmp=$(mktemp -p /tmp gitstat-json.XXXXXXXXXX)
    msg=$(mktemp -p /tmp git-commit-msg.XXXXXXXXX)

    if [[ -n $git_status ]]; then
      (git_status_json | jq) > $tmp
    else
      echo 'Nothing to commit'; exit 0
    fi

    parse_json 2>/dev/null

    cat $msg

    if confirm; then
      git commit -F $msg
    fi
  }

  main; rm -f $tmp $msg; exit
''
