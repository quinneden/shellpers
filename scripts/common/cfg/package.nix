{
  gawk,
  fd,
  installShellFiles,
  lib,
  micro,
  stdenv,
  writeShellScript,
  writeText,
}:
let
  binPath = lib.makeBinPath [
    gawk
    fd
    micro
  ];

  platform = if stdenv.isDarwin then "darwin" else "nixos";

  script = writeShellScript "cfg" ''
    PATH="${binPath}:$PATH"

    dotfiles_path="$HOME/.dotfiles"
    pos="''${1:-}"
    system="${platform}"

    # Check if dotfiles directory exists
    if [[ ! -d "$dotfiles_path" ]]; then
      echo "Error: Dotfiles directory '$dotfiles_path' not found." >&2
      exit 1
    fi

    # Determine search pattern based on input
    if [[ -z $pos ]]; then
      pat="flake.nix"
    elif [[ $pos =~ ^(hosts|home|overlays|pkgs|modules)(/[[:alnum:]_-]+)*/?$ ]]; then
      # Direct path match (allow hyphens and underscores in names)
      pat="$pos"
    else
      # Fuzzy filename search within known directories
      pat="(hosts|home|overlays|pkgs|modules)/(.+/)?.*$pos.*\.nix$"
    fi

    # Find matching files
    mapfile -t files_matched < <(
      fd --regex "$pat" -e nix --full-path "$dotfiles_path" 2>/dev/null |
      awk -F/ '{ print NF-1, $0 }' | sort -n | cut -d' ' -f2-
    )

    # Check if any files were found
    if [[ ''${#files_matched[@]} -eq 0 ]]; then
      echo "No files matching '$pos' found in $dotfiles_path" >&2
      exit 1
    fi

    # If only one file found, open it directly
    if [[ ''${#files_matched[@]} -eq 1 ]]; then
      micro "''${files_matched[0]}"
      exit 0
    fi

    # Multiple files found, let user choose
    chosen=""
    for file in "''${files_matched[@]}"; do
      relpath="''${file#$dotfiles_path/}"
      color="\033[96m"
      reset="\033[0m"

      while true; do
        printf "Open ''${color}''${relpath}''${reset}? (Y/n/q) "
        read -r -n 1 REPLY
        echo  # Add newline after single character input

        case $REPLY in
          [yY]|"")
            chosen="$file"
            break 2
            ;;
          [nN])
            break
            ;;
          [qQ])
            echo "Cancelled."
            exit 0
            ;;
          *)
            echo "Please enter y, n, or q."
            ;;
        esac
      done
    done

    if [[ -n $chosen ]]; then
      micro "$chosen"
    else
      echo "No file selected."
    fi
  '';

  cfgCompletion = writeText "_cfg" ''
    #compdef cfg

    _cfg() {
      local -a completions
      local dotfiles_path="$HOME/.dotfiles"

      # If dotfiles directory doesn't exist, fall back to basic file completion
      if [[ ! -d "$dotfiles_path" ]]; then
        _files -g '*.nix'
        return
      fi

      # Get the current word being completed
      local current_word="''${words[CURRENT]}"

      # If no argument yet, suggest common patterns and directories
      if [[ -z "$current_word" ]]; then
        completions=(
          "flake.nix:Main flake configuration"
          "hosts:Host configurations"
          "home:Home manager configurations"
          "modules:Nix modules"
          "overlays:Package overlays"
          "pkgs:Custom packages"
        )
        _describe 'cfg patterns' completions
        return
      fi

      # Generate fuzzy completions based on current input
      local pattern

      # Check if it's a directory pattern first
      if [[ "$current_word" =~ ^(hosts|home|overlays|pkgs|modules)(/.*)?$ ]]; then
        pattern="$current_word"
      else
        # Create fuzzy pattern for filename matching
        pattern="(hosts|home|overlays|pkgs|modules)/(.+/)?.*$current_word"
      fi

      # Use fd to find matching files, similar to the main script (zsh-compatible)
      if command -v fd >/dev/null 2>&1; then
        local -a matches
        matches=("''${(@f)$(
          fd --regex "$pattern" -e nix --full-path "$dotfiles_path" 2>/dev/null |
          head -20
        )}")

        # Convert full paths to relative paths and create completions
        for file in "''${matches[@]}"; do
          if [[ -n "$file" ]]; then
            local relpath="''${file#$dotfiles_path/}"
            local basename="''${relpath##*/}"

            # For fuzzy matching, suggest just the basename but show full path as description
            if [[ "$current_word" != */* ]]; then
              # Extract just the filename without .nix extension for completion
              local completion_word="''${basename%.nix}"
              # Avoid duplicates
              if [[ ! " ''${completions[@]} " =~ " $completion_word:" ]]; then
                completions+=("$completion_word:$relpath")
              fi
            else
              # For path-based completion, suggest the full relative path
              completions+=("$relpath:Nix configuration file")
            fi
          fi
        done
      fi

      # If we have matches, show them
      if (( ''${#completions[@]} > 0 )); then
        _describe 'nix files' completions
      else
        # Fall back to basic file completion in dotfiles directory
        _files -W "$dotfiles_path" -g '*.nix'
      fi
    }

    # Register the completion function
    compdef _cfg cfg
  '';
in
stdenv.mkDerivation rec {
  name = "cfg";
  src = ./.;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/zsh/site-functions
    install -m 755 ${script} $out/bin/${name}
    installShellCompletion --zsh ${cfgCompletion}
    runHook postInstall
  '';
}
