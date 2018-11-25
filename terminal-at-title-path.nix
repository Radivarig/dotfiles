{ pkgs, ... }:
pkgs.writeShellScriptBin "terminal-at-title-path" ''
  # opens a new terminal at path contained in the focused window title
  title="$(${pkgs.xdotool}/bin/xdotool getactivewindow getwindowname)"
  # get everything from first to last slash
  CURRENT_PATH=$(echo ''${title} | ${pkgs.perl}/bin/perl -nE '$_ =~ m| ( ~?/[^\s]* ) |x; say "$1"')
  # emulate tilda expansion since path is used in a string
  CURRENT_PATH="''${CURRENT_PATH/\~/$HOME}"
  # if it is a file use parent dir
  [ -f "$CURRENT_PATH" ] && CURRENT_PATH="$(dirname $CURRENT_PATH)"
  cd "$CURRENT_PATH"
  i3-sensible-terminal
''