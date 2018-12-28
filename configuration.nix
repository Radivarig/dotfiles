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
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
  ];

  services.nixosManual.showManual = true;
  time.timeZone = "Europe/Zagreb";
  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;
  virtualisation.docker.enable = true;

  services.openssh.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

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
    programs.git = {
      enable = true;
      userName = "Radivarig";
      userEmail = "reslav.hollos@gmail.com";
    };

    home.packages = let
      my-python-packages = python-packages: with python-packages; [
        pylint
      ];
      python-with-my-packages = pkgs.python3.withPackages my-python-packages;
    in with pkgs; [
      trash-cli
      clipit hicolor-icon-theme

      source-code-pro # font
      vscode

      vlc
      pavucontrol

      kazam
      lxterminal

      tldr
      wget
      zip unzip

      hexchat

      python-with-my-packages

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
    '';

    services.compton.enable = true;
    services.compton.opacityRule = [
      "70:class_g *= 'Lxterminal'"
      "90:class_g *= 'Code'"
      "80:window_type = 'dock' && class_g = 'i3bar'"
      "70:class_g *= 'i3-frame'"
    ];

    home.sessionVariables = rec {
      TERMINAL="lxterminal";
    };

    home.file.".config/lxterminal/lxterminal.conf".text = import ./lxterminal.conf.nix { inherit pkgs; };

    home.file.".inputrc".text = ''
      $include /etc/inputrc
      set completion-ignore-case on
    '';

    programs.bash = let
      bash-history-per-terminal = import ./bash-history-per-terminal.nix {inherit pkgs; };
      less-color-vars = import ./less-color-vars.nix;
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
        export LESS="-R -X" # raw colors, keep output after exit
        ${less-color-vars}

        # skip saving some dangerous commands
        HISTIGNORE=' *:rm *:rmdir *:del *:sudo *'
        . ${bash-history-per-terminal}

        stty -ixon # disable "flow control" (ctrl+S/Q), for forward search

        parse_git_branch(){ git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1 /';}

        set_current_dir_as_title='echo -ne "\e]0; $(dirs)/\007"' # for terminal-at-title-path
        PROMPT_COMMAND="$set_current_dir_as_title;$PROMPT_COMMAND"

        # make cd clear and ls
        cd() { builtin cd "$@" && clear && ls --group-directories-first ; }

        # prompt string
        SHELL_NAME=`[[ ! -z $name ]] && echo "$name"`
        PS1='\[\e[94m\]$SHELL_NAME \[\e[32m\]`parse_git_branch`\[\e[90m\]λ \[\e[00m\]'
        echo -ne "\e]12;cyan\a" # cursor color
        echo -e -n "\x1b[\x35 q" # cursor blinking bar
      '';

      shellAliases = {
        ".." = "cd ..";
        "cd.." = "cd ..";
        "..." = "cd ../..";

        mkdir = "mkdir -pv"; # create parent
        del = "trash-put";

        nr = ''nix repl "<nixpkgs>" "<nixpkgs/nixos>"'';
        ns = ''nix-shell --command "/run/current-system/sw/bin/bash" '';
        nb = "nix-build";

        # add prompt
        mv = "mv -i";
        cp = "cp -i";
        rm = "rm -i";

        gl = "git log --all --decorate --oneline --graph";
        gd = "git diff";
        gds = "git diff --staged";
        gs = "git status";
        ga = "git add";
        gap = "git add --patch";
        gc = "git commit --message";
        gca = "git commit --amend";
        gb = "git branch --all";
        gcp = "git cherry-pick";
        gp = "git pull";
        gm = "git merge";
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
    xsession.windowManager.i3 = rec {
      enable = true;

      # config.statusCommand = "${pkgs.i3blocks}";
      config.modifier = "Mod4";
      config.keybindings = let
        mod = config.modifier;
        resizeSmall = "1"; resizeBig = "5";
      # todo: generate arrows/hjkl bindings over functions
      terminal-at-title-path = import ./terminal-at-title-path.nix {inherit pkgs;};
      in {
        "Shift+Escape"         = "exec echo ''";
        "XF86AudioMute"        = "exec amixer sset 'Master' toggle";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -7%";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +3%";

        "XF86MonBrightnessUp"   = "exec ${pkgs.xorg.xbacklight}/bin/xbacklight -inc 7";
        "XF86MonBrightnessDown" = "exec ${pkgs.xorg.xbacklight}/bin/xbacklight -dec 3";

        "${mod}+F11" = "exec compton-trans -c -7";
        "${mod}+F12" = "exec compton-trans -c +3";

        "${mod}+Return" = "exec ${terminal-at-title-path}/bin/terminal-at-title-path";
        "${mod}+Shift+q" = "kill";
        "${mod}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run -i";

        # move focus/move hjkl
        "${mod}+h"  = "focus left";
        "${mod}+j"  = "focus down";
        "${mod}+k"    = "focus up";
        "${mod}+l" = "focus right";

        "${mod}+Shift+h"  = "move left";
        "${mod}+Shift+j"  = "move down";
        "${mod}+Shift+k"    = "move up";
        "${mod}+Shift+l" = "move right";

        # # move focus/move arrows
        "${mod}+Left"  = "focus left";
        "${mod}+Down"  = "focus down";
        "${mod}+Up"    = "focus up";
        "${mod}+Right" = "focus right";

        "${mod}+Shift+Left"  = "move left";
        "${mod}+Shift+Down"  = "move down";
        "${mod}+Shift+Up"    = "move up";
        "${mod}+Shift+Right" = "move right";

        "${mod}+v" = "split v";
        "${mod}+b" = "split h";
        "${mod}+f" = "fullscreen toggle";

        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";

        "${mod}+Shift+space" = "floating toggle";
        "${mod}+Tab" = "focus mode_toggle";
        "${mod}+minus" = "sticky toggle";

        "${mod}+a" = "focus parent";
        "${mod}+z" = "focus child";

        "${mod}+1" = "workspace 1";
        "${mod}+2" = "workspace 2";
        "${mod}+3" = "workspace 3";
        "${mod}+4" = "workspace 4";
        "${mod}+5" = "workspace 5";
        "${mod}+6" = "workspace 6";
        "${mod}+7" = "workspace 7";
        "${mod}+8" = "workspace 8";
        "${mod}+9" = "workspace 9";

        "${mod}+Shift+1" = "move container to workspace 1";
        "${mod}+Shift+2" = "move container to workspace 2";
        "${mod}+Shift+3" = "move container to workspace 3";
        "${mod}+Shift+4" = "move container to workspace 4";
        "${mod}+Shift+5" = "move container to workspace 5";
        "${mod}+Shift+6" = "move container to workspace 6";
        "${mod}+Shift+7" = "move container to workspace 7";
        "${mod}+Shift+8" = "move container to workspace 8";
        "${mod}+Shift+9" = "move container to workspace 9";

        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";

        # resize (also mod + rmb)
        "${mod}+Ctrl+Left"  = "resize shrink width  ${resizeSmall} px or ${resizeSmall} ppt";
        "${mod}+Ctrl+Down"  = "resize shrink height ${resizeSmall} px or ${resizeSmall} ppt";
        "${mod}+Ctrl+Up"    = "resize grow   height ${resizeSmall} px or ${resizeSmall} ppt";
        "${mod}+Ctrl+Right" = "resize grow   width  ${resizeSmall} px or ${resizeSmall} ppt";

        "${mod}+Ctrl+Shift+Left"  = "resize shrink width  ${resizeBig} px or ${resizeBig} ppt";
        "${mod}+Ctrl+Shift+Down"  = "resize shrink height ${resizeBig} px or ${resizeBig} ppt";
        "${mod}+Ctrl+Shift+Up"    = "resize grow   height ${resizeBig} px or ${resizeBig} ppt";
        "${mod}+Ctrl+Shift+Right" = "resize grow   width  ${resizeBig} px or ${resizeBig} ppt";

        # resize for hjkl
        "${mod}+Ctrl+h"  = "resize shrink width  ${resizeSmall} px or ${resizeSmall} ppt";
        "${mod}+Ctrl+j"  = "resize shrink height ${resizeSmall} px or ${resizeSmall} ppt";
        "${mod}+Ctrl+k"  = "resize grow   height ${resizeSmall} px or ${resizeSmall} ppt";
        "${mod}+Ctrl+l"  = "resize grow   width  ${resizeSmall} px or ${resizeSmall} ppt";

        "${mod}+Ctrl+Shift+h"  = "resize shrink width  ${resizeBig} px or ${resizeBig} ppt";
        "${mod}+Ctrl+Shift+j"  = "resize shrink height ${resizeBig} px or ${resizeBig} ppt";
        "${mod}+Ctrl+Shift+k"  = "resize grow   height ${resizeBig} px or ${resizeBig} ppt";
        "${mod}+Ctrl+Shift+l"  = "resize grow   width  ${resizeBig} px or ${resizeBig} ppt";

      };
    };
  } [
  ];
}
