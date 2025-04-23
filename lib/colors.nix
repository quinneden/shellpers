let
  esc = builtins.fromJSON ''"\u001b"'';
in
{
  BOLD = "${esc}[1m";
  RESET = "${esc}[0m";
  REVERSE = "${esc}[7m";
  UNDERLINE = "${esc}[4m";

  BLACK = "${esc}[30m";
  RED = "${esc}[31m";
  GREEN = "${esc}[32m";
  YELLOW = "${esc}[33m";
  BLUE = "${esc}[34m";
  MAGENTA = "${esc}[35m";
  CYAN = "${esc}[36m";
  WHITE = "${esc}[37m";

  BRIGHT_BLACK = "${esc}[90m";
  BRIGHT_RED = "${esc}[91m";
  BRIGHT_GREEN = "${esc}[92m";
  BRIGHT_YELLOW = "${esc}[93m";
  BRIGHT_BLUE = "${esc}[94m";
  BRIGHT_MAGENTA = "${esc}[95m";
  BRIGHT_CYAN = "${esc}[96m";
  BRIGHT_WHITE = "${esc}[97m";

  BG_BLACK = "${esc}[40m";
  BG_RED = "${esc}[41m";
  BG_GREEN = "${esc}[42m";
  BG_YELLOW = "${esc}[43m";
  BG_BLUE = "${esc}[44m";
  BG_MAGENTA = "${esc}[45m";
  BG_CYAN = "${esc}[46m";
  BG_WHITE = "${esc}[47m";

  BG_BRIGHT_BLACK = "${esc}[100m";
  BG_BRIGHT_RED = "${esc}[101m";
  BG_BRIGHT_GREEN = "${esc}[102m";
  BG_BRIGHT_YELLOW = "${esc}[103m";
  BG_BRIGHT_BLUE = "${esc}[104m";
  BG_BRIGHT_MAGENTA = "${esc}[105m";
  BG_BRIGHT_CYAN = "${esc}[106m";
  BG_BRIGHT_WHITE = "${esc}[107m";
}
