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
    ./vscode/default.nix
    ./lxterminal/default.nix
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
  ];

  services.nixosManual.showManual = true;
  time.timeZone = "Europe/Zagreb";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (self: super: rec {
      # override to add https://github.com/acrisci/i3ipc-glib/pull/9
      i3ipc-glib = super.i3ipc-glib.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "acrisci";
          repo = "i3ipc-glib";
          rev = "97ec9a4c5bf0d62572c918b86d31e81691b755d2";
          sha256 = "04slhnwyyzj97xc9j8y7ggsfqwx955cci1g5phkb1rak1nq4s9p1";
        };
      });
      i3-easyfocus = super.i3-easyfocus.override { inherit i3ipc-glib; };
    })
  ];

  networking.networkmanager.enable = true;
  virtualisation.docker.enable = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

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
      extraConfig = {
        core = {
          whitespace = "cr-at-eol";
        };
      };
    };

    home.packages = with pkgs; [
      ranger highlight
      trash-cli
      bc
      qdirstat

      pciutils # lspci setpci
      rlwrap

      python36Packages.mps-youtube

      # udiskie
      # sshfs


      clipit hicolor-icon-theme

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
      i3-easyfocus

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
    services.compton.opacityRule = [
      "80:window_type = 'dock' && class_g = 'i3bar'"
      "70:class_g *= 'i3-frame'"
    ];

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
        cd() { builtin cd "$@" && clear && ls --group-directories-first ; }

        # prompt string
        SHELL_NAME=`[[ ! -z $name ]] && echo "$name "`
        PS1='\[\e[33m\]$SHELL_NAME\[\e[32m\]`parse_git_branch`\[\e[90m\]λ \[\e[00m\]'
        echo -ne "\e]12;cyan\a" # cursor color
        echo -e -n "\x1b[\x35 q" # cursor blinking bar
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

        gl = "git log";
        gla = "git log --all --decorate --oneline --graph";
        gd = "git diff";
        gds = "git diff --staged";
        gs = "git status";
        ga = "git add";
        gap = "git add --patch";
        gc = "git commit --message";
        gca = "git commit --amend";
        gch = "git checkout";
        gb = "git branch --all";
        gcp = "git cherry-pick";
        gp = "git pull";
        gm = "git merge";
        ggwp = "git push origin HEAD";

        youtube = "mpsyt";
        pingu = "ping -c 3 google.com";
      };
    };

    programs.emacs.enable = true;

    programs.chromium.enable = true;

    xsession.enable = true;
    xsession.initExtra = let
      i3-focus-last = import ./i3-focus-last.nix { inherit pkgs; };
    in ''
      ${pkgs.xorg.xmodmap}/bin/xmodmap ~/.Xmodmap

      xcape -e 'Control_L=Escape' # trigger escape on single lctrl

      ${pkgs.xlibs.xset}/bin/xset r rate 200 60  # keyboard repeat rate

      while true; do ${pkgs.feh}/bin/feh -z --bg-fill ~/Downloads/Wallpapers;
        sleep $((5*60)); done &

      ${i3-focus-last} &
    '';
    xsession.windowManager.i3 = rec {
      enable = true;

      extraConfig = ''
        for_window [class=.*] border normal 1
        for_window [class=".*"] title_format "<span>%title</span>"
        font pango:DejaVu Sans Mono 10
      '';

      config.startup = [
        {command = "${pkgs.clipit}/bin/clipit";}
        {command = "${pkgs.hexchat}/bin/hexchat";}
      ];

      config.bars = let
      in [{
        fonts = ["DejaVu Sans Mono 10"];
        colors = rec {
          background = "#22222299";
          focusedWorkspace = activeWorkspace;
          activeWorkspace = {
            border = "#535F7F";
            background = "#535F7F";
            text = "#ffffff";
          };
        };
      }];
      config.floating.border = 0;
      config.window = {
        border = 1;
      };
      config.colors = rec {
        focused = {
          background = "#535F7F";
          border = "#535F7F";
          childBorder = "#535F7F";
          indicator = "#535F7F";
          text = "#ffffff";
        };

        focusedInactive = unfocused;
        placeholder = unfocused;

        unfocused = {
          background = "#222222";
          border = "#000000";
          childBorder = "#000000";
          indicator = "#000000";
          text = "#888888";
        };

        urgent = {
          background = "#900000";
          border = "#2f343a";
          childBorder = "#900000";
          indicator = "#900000";
          text = "#ffffff";
        };
      };

      config.modifier = "Mod4";
      config.keybindings = let
        mod = config.modifier;
        resizeSize = "5";
        center-mouse = pkgs.writeShellScriptBin "center-mouse" ''
          sh -c 'eval `${pkgs.xdotool}/bin/xdotool getactivewindow getwindowgeometry --shell`
          ${pkgs.xdotool}/bin/xdotool mousemove $((X+WIDTH/2)) $((Y+HEIGHT/2))'
        '';

      # todo: generate arrows/hjkl bindings over functions
      terminal-at-title-path = import ./terminal-at-title-path.nix {inherit pkgs;};
      in {
        "Shift+Escape"         = "exec echo ''"; # prevent chrome task manager
        "XF86AudioMute"        = "exec amixer sset 'Master' toggle";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -7%";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +3%";

        "XF86MonBrightnessDown" = "exec ${pkgs.xorg.xbacklight}/bin/xbacklight -dec 7";
        "XF86MonBrightnessUp"   = "exec ${pkgs.xorg.xbacklight}/bin/xbacklight -inc 3";

        "${mod}+F11" = "exec compton-trans -c -7";
        "${mod}+F12" = "exec compton-trans -c +3";

        "${mod}+Return" = "exec ${terminal-at-title-path}/bin/terminal-at-title-path";
        "${mod}+Shift+q" = "kill";
        "${mod}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run -i";
        "${mod}+f" = "exec ${pkgs.i3-easyfocus}/bin/i3-easyfocus";

        # move focus/move hjkl
        "${mod}+h" = "focus left; exec ${center-mouse}/bin/center-mouse";
        "${mod}+j" = "focus down; exec ${center-mouse}/bin/center-mouse";
        "${mod}+k" = "focus up; exec ${center-mouse}/bin/center-mouse";
        "${mod}+l" = "focus right; exec ${center-mouse}/bin/center-mouse";

        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        "${mod}+v" = "split v";
        "${mod}+b" = "split h";
        "${mod}+space" = "fullscreen toggle";

        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";

        "${mod}+Tab" = "[con_mark=_last_focused] focus";

        "${mod}+Shift+space" = "floating toggle";
        "${mod}+Shift+Tab" = "focus mode_toggle";
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
        "${mod}+Ctrl+Shift+h"  = "resize shrink width  ${resizeSize} px or ${resizeSize} ppt";
        "${mod}+Ctrl+Shift+j"  = "resize shrink height ${resizeSize} px or ${resizeSize} ppt";
        "${mod}+Ctrl+Shift+k"  = "resize grow   height ${resizeSize} px or ${resizeSize} ppt";
        "${mod}+Ctrl+Shift+l"  = "resize grow   width  ${resizeSize} px or ${resizeSize} ppt";
      };
    };
  } [
  ];
}
