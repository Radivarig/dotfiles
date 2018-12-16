# Bash History Per Terminal
# Updates each terminal with commands of all terminals on enter
#   while keeping each terminals commands at the end of its history list
# Source it from '~/.bashrc'

{ pkgs, ... }:
pkgs.writeScript "bash-history-per-terminal"
''
COMMON_HISTFILE="$HISTFILE" # file to which to append commands
TTY_HISTFILE="$HOME/.bhpt/tty_"`basename $(tty)`
"install" -D /dev/null "$TTY_HISTFILE"

clear_tty_history_list(){ "history" -c;}
flag_append_to_histfile(){ "history" -a;}
load_histfile_to_list(){ "history" -r;}

set_histfile_to_tty(){ HISTFILE="$TTY_HISTFILE";}
set_histfile_to_common(){ HISTFILE="$COMMON_HISTFILE";}

# TODO: prevent on sigint
prompt_cmd() {
  flag_append_to_histfile

  LAST_SESS_CMD=$(tail -n 1 "$TTY_HISTFILE")
  LAST_COMMON_CMD=$(tail -n 1 "$COMMON_HISTFILE")
  # append to common file, not multiple times, skip empty
  if [[ "$LAST_SESS_CMD" != "$LAST_COMMON_CMD" && "$LAST_SESS_CMD" != "" ]]
    then "echo" "$LAST_SESS_CMD" >> "$COMMON_HISTFILE"
  fi

  clear_tty_history_list
  set_histfile_to_common
  load_histfile_to_list
  set_histfile_to_tty
  load_histfile_to_list
}
PROMPT_COMMAND="prompt_cmd;$PROMPT_COMMAND"

# clear on exit
on_exit_tty(){ "rm" "$TTY_HISTFILE";}
"trap" on_exit_tty EXIT
''
