{ stdenv, writeShellScript }:
let
  inherit (import ../../../lib) colors;

  script = writeShellScript "colortable" ''
    show_reg() {
      echo "REG:"
      echo -e "${colors.BLACK}BLACK${colors.RESET}        ${colors.RED}RED${colors.RESET}        ${colors.GREEN}GREEN${colors.RESET}        ${colors.YELLOW}YELLOW${colors.RESET}        ${colors.BLUE}BLUE${colors.RESET}        ${colors.MAGENTA}MAGENTA${colors.RESET}        ${colors.CYAN}CYAN${colors.RESET}        ${colors.WHITE}WHITE${colors.RESET}"
      echo -e "${colors.BRIGHT_BLACK}BRIGHT_BLACK${colors.RESET} ${colors.BRIGHT_RED}BRIGHT_RED${colors.RESET} ${colors.BRIGHT_GREEN}BRIGHT_GREEN${colors.RESET} ${colors.BRIGHT_YELLOW}BRIGHT_YELLOW${colors.RESET} ${colors.BRIGHT_BLUE}BRIGHT_BLUE${colors.RESET} ${colors.BRIGHT_MAGENTA}BRIGHT_MAGENTA${colors.RESET} ${colors.BRIGHT_CYAN}BRIGHT_CYAN${colors.RESET} ${colors.BRIGHT_WHITE}BRIGHT_WHITE${colors.RESET}"
    }

    show_bold_reg() {
      echo "BOLD:"
      echo -e "${colors.BOLD}${colors.BLACK}BLACK${colors.RESET}        ${colors.RED}RED${colors.RESET}        ${colors.GREEN}GREEN${colors.RESET}        ${colors.YELLOW}YELLOW${colors.RESET}        ${colors.BLUE}BLUE${colors.RESET}        ${colors.MAGENTA}MAGENTA${colors.RESET}        ${colors.CYAN}CYAN${colors.RESET}        ${colors.WHITE}WHITE${colors.RESET}"
      echo -e "${colors.BOLD}${colors.BRIGHT_BLACK}BRIGHT_BLACK${colors.RESET} ${colors.BRIGHT_RED}BRIGHT_RED${colors.RESET} ${colors.BRIGHT_GREEN}BRIGHT_GREEN${colors.RESET} ${colors.BRIGHT_YELLOW}BRIGHT_YELLOW${colors.RESET} ${colors.BRIGHT_BLUE}BRIGHT_BLUE${colors.RESET} ${colors.BRIGHT_MAGENTA}BRIGHT_MAGENTA${colors.RESET} ${colors.BRIGHT_CYAN}BRIGHT_CYAN${colors.RESET} ${colors.BRIGHT_WHITE}BRIGHT_WHITE${colors.RESET}"
    }

    show_bg_reg() {
      echo "BACKGROUND:"
      echo -e "${colors.REVERSE}${colors.BLACK}BLACK${colors.RESET}        ${colors.REVERSE}${colors.RED}RED${colors.RESET}        ${colors.REVERSE}${colors.GREEN}GREEN${colors.RESET}        ${colors.REVERSE}${colors.YELLOW}YELLOW${colors.RESET}        ${colors.REVERSE}${colors.BLUE}BLUE${colors.RESET}        ${colors.REVERSE}${colors.MAGENTA}MAGENTA${colors.RESET}        ${colors.REVERSE}${colors.CYAN}CYAN${colors.RESET}        ${colors.REVERSE}${colors.WHITE}WHITE${colors.RESET}"
      echo -e "${colors.REVERSE}${colors.BRIGHT_BLACK}BRIGHT_BLACK${colors.RESET} ${colors.REVERSE}${colors.BRIGHT_RED}BRIGHT_RED${colors.RESET} ${colors.REVERSE}${colors.BRIGHT_GREEN}BRIGHT_GREEN${colors.RESET} ${colors.REVERSE}${colors.BRIGHT_YELLOW}BRIGHT_YELLOW${colors.RESET} ${colors.REVERSE}${colors.BRIGHT_BLUE}BRIGHT_BLUE${colors.RESET} ${colors.REVERSE}${colors.BRIGHT_MAGENTA}BRIGHT_MAGENTA${colors.RESET} ${colors.REVERSE}${colors.BRIGHT_CYAN}BRIGHT_CYAN${colors.RESET} ${colors.REVERSE}${colors.BRIGHT_WHITE}BRIGHT_WHITE${colors.RESET}"
    }

    show_reg_swatch() {
      echo "REG:"
      echo "BLACK RED   GREEN YEL.  BLUE  MAG.  CYAN  WHITE"
      echo -e "${colors.BG_BLACK}     ${colors.RESET} ${colors.BG_RED}     ${colors.RESET} ${colors.BG_GREEN}     ${colors.RESET} ${colors.BG_YELLOW}     ${colors.RESET} ${colors.BG_BLUE}     ${colors.RESET} ${colors.BG_MAGENTA}     ${colors.RESET} ${colors.BG_CYAN}     ${colors.RESET} ${colors.BG_WHITE}     ${colors.RESET}"
      echo -e "${colors.BG_BLACK}     ${colors.RESET} ${colors.BG_RED}     ${colors.RESET} ${colors.BG_GREEN}     ${colors.RESET} ${colors.BG_YELLOW}     ${colors.RESET} ${colors.BG_BLUE}     ${colors.RESET} ${colors.BG_MAGENTA}     ${colors.RESET} ${colors.BG_CYAN}     ${colors.RESET} ${colors.BG_WHITE}     ${colors.RESET}"
    }

    show_bright_swatch() {
      echo "BRIGHT:"
      echo "BLACK RED   GREEN YEL.  BLUE  MAG.  CYAN  WHITE"
      echo -e "${colors.BG_BRIGHT_BLACK}     ${colors.RESET} ${colors.BG_BRIGHT_RED}     ${colors.RESET} ${colors.BG_BRIGHT_GREEN}     ${colors.RESET} ${colors.BG_BRIGHT_YELLOW}     ${colors.RESET} ${colors.BG_BRIGHT_BLUE}     ${colors.RESET} ${colors.BG_BRIGHT_MAGENTA}     ${colors.RESET} ${colors.BG_BRIGHT_CYAN}     ${colors.RESET} ${colors.BG_BRIGHT_WHITE}     ${colors.RESET}"
      echo -e "${colors.BG_BRIGHT_BLACK}     ${colors.RESET} ${colors.BG_BRIGHT_RED}     ${colors.RESET} ${colors.BG_BRIGHT_GREEN}     ${colors.RESET} ${colors.BG_BRIGHT_YELLOW}     ${colors.RESET} ${colors.BG_BRIGHT_BLUE}     ${colors.RESET} ${colors.BG_BRIGHT_MAGENTA}     ${colors.RESET} ${colors.BG_BRIGHT_CYAN}     ${colors.RESET} ${colors.BG_BRIGHT_WHITE}     ${colors.RESET}"
    }

    show_reg; echo
    show_bold_reg; echo
    show_bg_reg; echo
    show_reg_swatch; echo
    show_bright_swatch
  '';
in
stdenv.mkDerivation rec {
  name = "colortable";
  src = ./.;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 ${script} $out/bin/${name}
    runHook postInstall
  '';
}
