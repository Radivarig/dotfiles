{pkgs, ...}: with pkgs;
let
bash-history-per-terminal = import ./bash-history-per-terminal.nix;
in
{
  programs.bash = rec {
    historyFile = "$HOME/.history";
    historySize = 10000;

    # not called for subshells
    profileExtra = ''
      # TODO: cleanup by regex
      # TODO: keep a separate file of useful not-to-be-lost commands

      # dedupe history lines and keep last occurance
      "tac" "${historyFile}" | "awk" '!x[$0]++' | \
      "tac" > "${historyFile}""__tmp"; "mv" "${historyFile}""__tmp" ${historyFile}
    '';

    sessionVariables = rec {
      EDITOR="nano";
      TERM="xterm-256color"; # make backspace work in ssh
      LESS="-R -X"; # raw colors, keep output after exit
      MANWIDTH="3000"; # have manpages not trim lines to initial terminal size otherwise fullscreen is useless
    };

    initExtra = ''
      # TODO: fix cleaning up ~/.bhpt, maybe rename it to .bash_histories
      ${bash-history-per-terminal}

      # skip saving some dangerous commands
      HISTIGNORE=' *:rm *:rmdir *:del *:fg:bg'
    '';

  };
}
