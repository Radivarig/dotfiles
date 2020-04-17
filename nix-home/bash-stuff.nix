{pkgs, ...}: with pkgs;
let
less-color-vars = import ./less-color-vars.nix;
set-PS1 = import ./set-PS1.nix;
in
{

  home.file.".inputrc".text = ''
    $include /etc/inputrc
    set completion-ignore-case on
    set enable-bracketed-paste on
  '';

  programs.bash = {
    enable = true;
    enableAutojump = true;

    sessionVariables = rec {
      EDITOR="nano";
    };

    initExtra = ''
      # important to export, to avoid clearing of PROMPT_COMMAND
      # make backspace work in ssh
      export TERM="xterm-256color"

      # raw colors, keep output after exit
      export LESS="-R -X"

      # have manpages not trim lines, for fullscreen
      export MANWIDTH="3000"

      ${less-color-vars}
      ${set-PS1}

      # for terminal-at-title-path
      set_current_dir_as_title='echo -ne "\e]0; $(dirs +0)/\007"'
      PROMPT_COMMAND="$set_current_dir_as_title;$PROMPT_COMMAND"

      echo -ne "\e]12;cyan\a" # cursor color
      echo -ne "\x1b[\x36 q" # cursor non-blinking bar

      stty -ixon # disable "flow control" (ctrl+S/Q), to free forward search

      # make cd pushd, clear and ls. use `popd` to go back
      cd() {
        if [ $# -eq 0 ]; then DIR="$HOME"; else DIR="$1"; fi
        builtin pushd "$DIR" && ${busybox}/bin/clear -x && ls --group-directories-first
      }

      # cd into archive as read-only
      cda() {
        local tmp_dir=$(mktemp -d /tmp/foo.XXXXXXXXX)
        ${archivemount}/bin/archivemount -o readonly "$@" $tmp_dir && cd $tmp_dir
      }

      function cdb { if [ $1 -ne 0 ]; then { cd ..; cdb $[$1-1]; }; fi }

      function nsp { nix-shell --command "export name='$*' ;/run/current-system/sw/bin/bash" -p $@; }

      # for symlink chains use `namei`
      wlg() { pushd $(dirname $(which "$1")); l | grep "$1"; popd; } # which, list, grep
    '';

    # TODO: move package specific to separate files
    shellAliases = {
      ".." = "cd ..";
      "cd.." = "cd ..";
      "..." = "cd ../..";

      bc = "${pkgs.bc}/bin/bc --mathlib";
      lsblk="lsblk -o NAME,TYPE,FSTYPE,LABEL,UUID,SIZE,MOUNTPOINT";

      grep="grep --color";
      reset="${pkgs.busybox}/bin/reset; source ~/.bashrc";

      mkdir = "mkdir -pv"; # create parent
      del = "trash-put";
      r = "ranger-cd";

      nr = ''nix repl "<nixos-unstable>"'';
      ns = ''nix-shell --command "/run/current-system/sw/bin/bash" '';
      nb = "nix-build";

      # add prompt
      mv = "mv -i";
      cp = "cp -i";
      rm = ''echo Use "del" instead of "rm".; exit 1'';

      youtube = "mpsyt";
      pingu = "ping -c 3 google.com";

      alias = "#";
    };
  };

}
