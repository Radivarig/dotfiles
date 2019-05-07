{ config, pkgs, ... }:

# todo: separate to files
# todo: use full paths from ${pkgs.package}/bin/package
{
  imports = [
    ./hardware-configuration.nix # hardware scan results
    ./boot.nix
    ./cachix.nix
    ./printer.nix
    ./display-manager.nix
    ./termite.nix
    ./vscode/default.nix
    ./i3/default.nix
    ./hidpi.nix
    ./git.nix
    ./screen-locker.nix

    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/release-18.09.tar.gz}/nixos"
  ];

  services.nixosManual.showManual = true;
  time.timeZone = "Europe/Zagreb";

  nixpkgs.config.allowUnfree = true;

  services.xserver.enable = true;

  networking.networkmanager.enable = true;
  virtualisation.docker.enable = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  # change ONLY after NixOS release notes say so (db servers can break)
  system.stateVersion = "18.09"; # Did you read the comment?

  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
    tapButtons = false;
    additionalOptions = ''
      Option "TapButton3" "2"
    '';
  };

  users.users.radivarig = {
    isNormalUser = true; # set some defaults
    extraGroups = [ "wheel" "docker" ];
    uid = 1000;
  };

  home-manager.users.radivarig = with pkgs.lib; foldr (a: b: (attrsets.recursiveUpdate a b)) {

    home.packages = with pkgs; [
      blueman

      ranger highlight
      trash-cli
      bc
      qdirstat

      pciutils # lspci setpci
      rlwrap

      python36Packages.mps-youtube

      # udiskie
      # sshfs


      clipster
      

      source-code-pro # font

      vlc
      pavucontrol

      kazam

      tldr
      wget
      zip unzip
      lsof
      htop

      hexchat

      ghc
      cabal-install
      haskellPackages.hoogle

      xcape
      xorg.xhost
      xorg.xkill
      xorg.xev
      xorg.xmodmap


      feh
      nodejs-10_x
    ];

    # todo: extend xkb layout
    home.file.".Xmodmap".text = ''
      ! ctrl to capslock
      clear lock
      clear control
      keycode 66 = Control_L
      add control = Control_L Control_R

      ! set ralt to modeswitch
      keycode 108 = NoSymbol NoSymbol
      keycode 108 = Mode_switch

      ! rctrl to backspace
      keycode 105 = BackSpace

      ! ralt + hjkl to arrows
      keysym h = h H Left NoSymbol NoSymbol NoSymbol
      keysym j = j J Down NoSymbol NoSymbol NoSymbol
      keysym k = k K Up NoSymbol NoSymbol NoSymbol
      keysym l = l L Right NoSymbol lstroke Lstroke

      ! rshift to enter
      keycode 62 = Return

      ! add Tab to Alt_L
      keycode 64 = Tab ISO_Left_Tab Tab ISO_Left_Tab
    '';

    services.compton.enable = true;

    home.file.".config/ranger/rc.conf".text = ''
      map <DELETE> shell -s trash-put %s
      set show_hidden true
    '';
    home.file.".config/ranger/plugins/cd_to_title.py".text = ''
      import ranger.api
      import os
      import sys

      old_hook_init = ranger.api.hook_init

      def hook_init(fm):
          def on_cd():
              if fm.thisdir:
                  title = os.path.basename(fm.thisdir.path)
                  sys.stdout.write("\033k"+title+"\033\\")
                  sys.stdout.flush()

          fm.signal_bind('cd', on_cd)
          return old_hook_init(fm)

      ranger.api.hook_init = hook_init
    '';

    home.file.".inputrc".text = ''
      $include /etc/inputrc
      set completion-ignore-case on
      set enable-bracketed-paste on
    '';


    programs.bash = let
      bash-history-per-terminal = import ./bash-history-per-terminal.nix {inherit pkgs; };
      less-color-vars = import ./less-color-vars.nix;
      ranger-cd = builtins.replaceStrings ["/usr/bin/ranger"] ["${pkgs.ranger}/bin/ranger"]
        (builtins.readFile "${pkgs.ranger.src}/examples/bash_automatic_cd.sh");
    in rec {
      enable = true;
      enableAutojump = true;

      historyFile = "$HOME/.history";
      historySize = 10000;

      # not called for subshells
      profileExtra = ''
        # dedupe history lines and keep last occurance
        "tac" "${historyFile}" | "awk" '!x[$0]++' | \
        "tac" > "${historyFile}""__tmp"; "mv" "${historyFile}""__tmp" ${historyFile}
      '';

      sessionVariables = rec {
        EDITOR="emacs -nw -q";
        GIT_EDITOR="${EDITOR}";
      };

      initExtra = ''
        TERM=xterm-256color # make backspace work in ssh
        export MANWIDTH=3000 # have manpages not trim lines to initial terminal size otherwise fullscreen is useless
        export LESS="-R -X" # raw colors, keep output after exit
        ${less-color-vars}

        # skip saving some dangerous commands
        HISTIGNORE=' *:rm *:rmdir *:del *:sudo *'
        . ${bash-history-per-terminal}

        ${ranger-cd}

        stty -ixon # disable "flow control" (ctrl+S/Q), to free forward search

        parse_git_branch(){ git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1 /';}

        set_current_dir_as_title='echo -ne "\e]0; $(dirs)/\007"' # for terminal-at-title-path
        PROMPT_COMMAND="$set_current_dir_as_title;$PROMPT_COMMAND"

        # make cd clear and ls
        cd() { builtin cd "$@" && ${pkgs.busybox}/bin/clear && ls --group-directories-first ; }

        # prompt string
        SHELL_NAME=`[[ ! -z $name ]] && echo "$name "`
        PS1='\[\e[33m\]$SHELL_NAME\[\e[32m\]`parse_git_branch`\[\e[90m\]λ \[\e[00m\]'
        echo -ne "\e]12;cyan\a" # cursor color
        echo -ne "\x1b[\x36 q" # cursor non-blinking bar
      '';

      shellAliases = {
        ".." = "cd ..";
        "cd.." = "cd ..";
        "..." = "cd ../..";

        mkdir = "mkdir -pv"; # create parent
        del = "trash-put";
        r = "ranger-cd";

        nr = ''nix repl "<nixpkgs>" "<nixpkgs/nixos>"'';
        ns = ''nix-shell --command "/run/current-system/sw/bin/bash" '';
        nb = "nix-build";

        # add prompt
        mv = "mv -i";
        cp = "cp -i";
        rm = ''echo Use "del" instead of "rm".; exit 1'';

        youtube = "mpsyt";
        pingu = "ping -c 3 google.com";
      };
    };

    programs.emacs.enable = true;
    programs.chromium.enable = true;

    xsession.enable = true;
    xsession.initExtra = ''
      ${pkgs.xorg.xmodmap}/bin/xmodmap ~/.Xmodmap

      xcape -e 'Control_L=Escape' # trigger escape on single lctrl

      ${pkgs.xlibs.xset}/bin/xset r rate 200 60  # keyboard repeat rate

      while true; do ${pkgs.feh}/bin/feh -z --bg-fill ~/Downloads/Wallpapers;
        sleep $((5*60)); done &
    '';
  } [
  ];
}
