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
append_new_to_file(){ \history -a;}
read_file_to_list(){ \history -r;}
write_list_to_file(){ \history -w;}

set_file_to_session(){ HISTFILE="$SESS_HISTFILE";}
set_file_to_common(){ HISTFILE="$COMMON_HISTFILE";}
set_file_to_tty(){ HISTFILE="$TTY_HISTFILE";}

prompt_cmd() {
  set_file_to_session
  append_new_to_file

  LAST_SESS=$(tail -n 1 "$SESS_HISTFILE")
  LAST_HIST=$(tail -n 1 "$COMMON_HISTFILE")

  if [[ "$LAST_SESS" != "$LAST_HIST" && "$LAST_SESS" != "" ]]
    then \echo "$LAST_SESS" >> "$COMMON_HISTFILE"
  fi
  clear_hist_list

  set_file_to_common
  read_file_to_list

  set_file_to_session
  read_file_to_list

  set_file_to_tty
  write_list_to_file
}
PROMPT_COMMAND="prompt_cmd;$PROMPT_COMMAND"

on_exit_tty(){ \rm "$TTY_HISTFILE"{,_session};}
\trap on_exit_tty EXIT
''
