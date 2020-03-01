{ config, pkgs, ... }:
let
  nixos-unstable = import <nixos-unstable> {config = {allowUnfree = true;};};
  # nixpkgs = import <nixpkgs> {config = { allowUnfree = true;};};
in
# todo: separate to files
# todo: use full paths from ${pkgs.package}/bin/package
{
  imports = [
    ./hardware-configuration.nix # hardware scan results
    ./boot.nix
    # ./cachix.nix
    # ./printer.nix # NOTE: broken in 19.09 unstable
    ./display-manager.nix
    ./termite.nix
    ./steam.nix
    ./vscode/default.nix
    ./i3/default.nix
    ./hidpi.nix
    ./git.nix
    ./screen-locker.nix

  # (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos")
  "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/release-19.09.tar.gz}/nixos"
  ];

  services.nixosManual.showManual = true;
  time.timeZone = "Europe/Zagreb";

  nixpkgs.config.allowUnfree = true;

  services.xserver = {
    enable = true;
    exportConfiguration = true;
  };

  services.xserver.resolutions = [{x = 1920; y = 1080;}];

  networking.firewall.allowedTCPPorts = [22 4200];
  networking.networkmanager.enable = true;

  virtualisation = {
    docker.enable = true;
    virtualbox.host.enable = true;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=0
  '';

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  hardware.brightnessctl.enable = true;

  # change ONLY after NixOS release notes say so (db servers can break)
  system.stateVersion = "18.09"; # Did you read the comment?

  # TODO: this does not work and services.xserver.synaptics.enable = false neither..
  # services.xserver.libinput.enable = false;
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
    extraGroups = [ "wheel" "video" "audio" "docker" "scanner" "vboxusers"];
    uid = 1000;
  };

  # TODO: move to home.activation # TODO: config.lib.dag missing
  # home.activation.greenclip = config.lib.dag.entryAfter [ "writeBoundary" ] ''
  #   ln -sf /etc/nixos/greenclip.cfg $HOME/.config/greenclip.cfg
  # '';
  system.activationScripts.stuff = ''
    ln -sf /etc/nixos/greenclip.cfg /home/radivarig/.config/greenclip.cfg
    ln -sf /bin/sh /bin/bash
  '';
  # hardware.bluetooth.enable = true;
  home-manager.users.radivarig = with pkgs.lib; foldr (a: b: (attrsets.recursiveUpdate a b)) {
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [
      nixos-unstable.blender
      nixos-unstable.spotify

      # nautilus
      ardour
      # qjackctl jack2
      guitarix
      gxplugins-lv2

      krita

      nixos-unstable.unityhub
      nixos-unstable.omnisharp-roslyn
      nixos-unstable.mono5
      dotnet-sdk

      wine
      freemind

      audio-recorder
      blueman

      irssi
      archivemount

      blueman
      simple-scan

      ranger highlight
      trash-cli
      bc
      qdirstat

      pciutils # lspci setpci
      telnet
      rlwrap

      wirelesstools
      inotify-tools
      swiProlog

      python3Packages.mps-youtube

      # udiskie
      # sshfs

      # hicolor-icon-theme # fallback icons for freedesktop.org

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
      haskellPackages.greenclip

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
      keycode 108 = NoSymbol NoSymbol NoSymbol NoSymbol
      keycode 108 = Mode_switch Mode_switch Mode_switch Mode_switch

      ! ralt + hjkl to arrows
      keysym h = h H Left NoSymbol
      keysym j = j J Down NoSymbol
      keysym k = k K Up NoSymbol
      keysym l = l L Right NoSymbol

      keysym g = g G Home
      keysym semicolon = semicolon colon End

      ! keypad numbers for mousekeys
      keysym y = y Y KP_4
      keysym u = u U KP_2
      keysym i = i I KP_8
      keysym o = o O KP_6

      ! keysym 8 = 8 asterisk Pointer_Button5
      ! keysym 9 = 9 parenleft Pointer_Button4
      keysym 0 = 0 parenright Pointer_Button1
      keysym minus = minus underscore Pointer_Button3
      keysym equal = equal plus Pointer_Button2
    '';

    services.compton = {
      enable = true;
      vSync = "opengl-swc";
    };

    home.file.".xbindkeysrc".text = ''
      # TODO: figure out mode_switch + <key> issue
      "${pkgs.xdotool}/bin/xdotool click 4"
        F10
      "${pkgs.xdotool}/bin/xdotool click 5"
        F9

      "echo ' '"
      Prior
      "echo ' '"
      Next
    '';

    home.file.".config/ranger/rc.conf".text = ''
      map <DELETE> shell -s trash-put %s
      set confirm_on_delete always
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
                  title = fm.thisdir.path
                  sys.stdout.write('\33]0;'+title+'\a')
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

    programs.rofi = let
    rofiThemes = pkgs.fetchFromGitHub {
      owner = "davatorium";
      repo = "rofi-themes";
      rev = "2088c73e4006f4b17d6ce75758c6f021e612d1c2";
      sha256 = "1jydnxqc4g4h2l7xh297kpixc1dyfjdp649ayp9bvclpxz1cwgd1";
    };
    in {
      enable = true;
      theme = "${rofiThemes}/User Themes/arc-red-dark.rasi";
    };

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
        EDITOR="vim";
        GIT_EDITOR="emacs -nw -q";
      };

      initExtra = ''
        TERM=xterm-256color # make backspace work in ssh
        export MANWIDTH=3000 # have manpages not trim lines to initial terminal size otherwise fullscreen is useless
        export LESS="-R -X" # raw colors, keep output after exit
        ${less-color-vars}

        # skip saving some dangerous commands
        HISTIGNORE=' *:rm *:rmdir *:del *:fg:bg'
        . ${bash-history-per-terminal}

        ${ranger-cd}
        bind '"\C-o":"ranger-cd\C-m"' # bind this explicitly, even though ranger-cd has this as a side-effect..

        stty -ixon # disable "flow control" (ctrl+S/Q), to free forward search

        append_space_if_defined(){ local str=$(echo "$*" | awk '{$1=$1};1'); echo "''${str:+$str }";}

        get_git_branch(){ git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/';}
        get_git_dirty(){ [[ ! -z "$(git status --porcelain 2> /dev/null)" ]] && echo "☢";}
        get_shell_name(){ [[ ! -z $name ]] && echo "$name";}

        set_current_dir_as_title='echo -ne "\e]0; $(dirs +0)/\007"' # for terminal-at-title-path
        PROMPT_COMMAND="$set_current_dir_as_title;$PROMPT_COMMAND"

        # make cd pushd, clear and ls. use `popd` to go back
        cd() {
          if [ $# -eq 0 ]; then DIR="$HOME"; else DIR="$1"; fi
          builtin pushd "$DIR" && ${pkgs.busybox}/bin/clear -x && ls --group-directories-first
        }

        # cd into archive as read-only
        cda() {
          local tmp_dir=$(mktemp -d /tmp/foo.XXXXXXXXX)
          archivemount -o readonly "$@" $tmp_dir && cd $tmp_dir
        }
        function cdb { if [ $1 -ne 0 ]; then { cd ..; cdb $[$1-1]; }; fi }
        function nsp { nix-shell --command "export name='$*' ;/run/current-system/sw/bin/bash" -p $@; }

        # for symlink chains use `namei`
        wlg() { pushd $(dirname $(which "$1")); l | grep "$1"; popd; } # which, list, grep

        # prompt string
        PS1='\
\[\e[33m\]`append_space_if_defined $(get_shell_name)`\
\[\e[32m\]`append_space_if_defined $(get_git_branch)`\
\[\e[93m\]`append_space_if_defined $(get_git_dirty)`\
\[\e[90m\]λ \
\[\e[00m\]'

        echo -ne "\e]12;cyan\a" # cursor color
        echo -ne "\x1b[\x36 q" # cursor non-blinking bar
      '';

      shellAliases = {
        ".." = "cd ..";
        "cd.." = "cd ..";
        "..." = "cd ../..";

        bc = "bc --mathlib";
        lsblk="lsblk -o NAME,TYPE,FSTYPE,LABEL,UUID,SIZE,MOUNTPOINT";

        grep="grep --color";
        reset="${pkgs.busybox}/bin/reset; source ~/.bashrc";

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

        alias = "#";
      };
    };

    programs.vim.enable = true;
    programs.emacs.enable = true;
    programs.chromium.enable = true;

    xsession.enable = true;

    home.file.".apply_keyboard_settings".text = ''
      ${pkgs.xorg.xinput}/bin/xinput disable $(${pkgs.xorg.xinput}/bin/xinput | grep -i touchpad | grep -oP '.*id=\K\d+')

      # compose [release + symbol + letter]: (/ đ) (< ž) (' ć)
      setxkbmap -model pc104 -layout us -option "compose:rctrl"
      ${pkgs.xorg.xmodmap}/bin/xmodmap ~/.Xmodmap
      xcape -e 'Control_L=Escape' # trigger escape on single lctrl
      ${pkgs.xbindkeys}/bin/xbindkeys -f ~/.xbindkeysrc

      ${pkgs.xkbset}/bin/xkbset r rate 200 20 # keyboard repeat rate
      ${pkgs.xkbset}/bin/xkbset m # enable mousekeys
      # xkbset ma [delay] [interval] [time to max] [max speed] [curve]
      ${pkgs.xkbset}/bin/xkbset ma 1 15 40 30 20 # mousekeys accelleration
      # TODO: why this stops working?? xkbset q | grep "Mouse Keys" shows "Mouse Keys: On"
      while true; do ${pkgs.xkbset}/bin/xkbset m; sleep 15; done
    '';

    xsession.initExtra = ''
      . ~/.apply_keyboard_settings &

      while true; do
        ${pkgs.feh}/bin/feh -z --recursive --bg-max ~/spacebase/wallpapers;
        sleep $((5*60)); done &
    '';
  } [
  ];
}
