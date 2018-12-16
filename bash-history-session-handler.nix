# Bash History Session Handler

# Updates each terminal with commands of all terminals on enter
#     while keeping the 'per-session commands' at the end

# source it from '~/.bashrc'
{ pkgs, ... }:
pkgs.writeScript "bash-history-session-handler" ''
COMMON_HISTFILE="$HISTFILE"
TTY_HISTFILE_FOLDER="$HOME"/.bhsh_tty
\mkdir -p "$TTY_HISTFILE_FOLDER"
TTY_HISTFILE="$TTY_HISTFILE_FOLDER"/bhsh_tty`basename $(tty)`
SESS_HISTFILE="$TTY_HISTFILE"_session
\cp /dev/null "$SESS_HISTFILE"

clear_hist_list(){ \history -c;}
set_flag_append_to_histfile(){ \history -a;}
read_histfile_to_list(){ \history -r;}
write_list_to_histfile(){ \history -w;}

set_histfile_to_session(){ HISTFILE="$SESS_HISTFILE";}
set_histfile_to_common(){ HISTFILE="$COMMON_HISTFILE";}
set_histfile_to_tty(){ HISTFILE="$TTY_HISTFILE";}

prompt_cmd() {
  set_histfile_to_session
  set_flag_append_to_histfile

  LAST_SESS=$(tail -n 1 "$SESS_HISTFILE")
  LAST_HIST=$(tail -n 1 "$COMMON_HISTFILE")

  # add to common file, only once, skip empty
  if [[ "$LAST_SESS" != "$LAST_HIST" && "$LAST_SESS" != "" ]]
    then \echo "$LAST_SESS" >> "$COMMON_HISTFILE"
  fi
  clear_hist_list

  set_histfile_to_common
  read_histfile_to_list

  set_histfile_to_session
  read_histfile_to_list

  set_histfile_to_tty
  write_list_to_histfile
}
PROMPT_COMMAND="prompt_cmd;$PROMPT_COMMAND"

on_exit_tty(){ \rm "$TTY_HISTFILE"{,_session};}
\trap on_exit_tty EXIT
''
