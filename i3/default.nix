{pkgs, ...}:
with pkgs;
let
i3-focus-last = import ./i3-focus-last.nix { inherit pkgs; };
user = "radivarig"; # TODO: use module options tom take this from configuration.nix
in {
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

  home-manager.users."${user}" = {
    home.packages = [i3-easyfocus];
    services.compton.opacityRule = [
      "80:window_type = 'dock' && class_g = 'i3bar'"
      "70:class_g *= 'i3-frame'"
    ];

    xsession.initExtra = ''${i3-focus-last} &'';

    xsession.windowManager.i3 = rec {
      enable = true;

      config.startup = [
        # TODO: move to file
        {command = "exec ${pkgs.haskellPackages.greenclip}/bin/greenclip daemon";}
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

      extraConfig = ''
        set $mod ${config.modifier}
        set $alt Mod1

        for_window [class=.*] border normal 1
        for_window [class=".*"] title_format "<span>%title</span>"
        font pango:DejaVu Sans Mono 10

        bindsym --release Print        exec "${scrot}/bin/scrot -m      ~/Screenshots/`date +%Y-%m-%d-%H-%M-%s`.png"
        bindsym --release Shift+Print  exec "${scrot}/bin/scrot -s      ~/Screenshots/`date +%Y-%m-%d-%H-%M-%s`.png"
        bindsym --release $mod+Print   exec "${scrot}/bin/scrot -u -d 4 ~/Screenshots/`date +%Y-%m-%d-%H-%M-%s`.png"
      '';
      config.keybindings = let
        resizeSize = "5";
        i3-set-split-by-size = pkgs.writeShellScriptBin "i3-set-split-by-size" ''
          sh -c 'eval `${pkgs.xdotool}/bin/xdotool getactivewindow getwindowgeometry --shell`
            if [ $((WIDTH*3/4)) -gt $HEIGHT ]; then ${i3}/bin/i3-msg split h; else ${i3}/bin/i3-msg split v; fi'
        '';
        center-mouse = pkgs.writeShellScriptBin "center-mouse" ''
          sh -c 'eval `${pkgs.xdotool}/bin/xdotool getactivewindow getwindowgeometry --shell`
          ${pkgs.xdotool}/bin/xdotool mousemove $((X+WIDTH/2)) $((Y+HEIGHT/2))'
        '';

      terminal-at-title-path = import ./terminal-at-title-path.nix {inherit pkgs;};
      in {
        "Shift+$alt+e" = ''exec ${pkgs.rofi}/bin/rofi -modi "clipboard:greenclip print" -show clipboard -run-command "{cmd}"'';
        "Shift+Escape"         = "exec echo ''"; # prevent chrome task manager
        "XF86AudioMute"        = "exec amixer sset 'Master' toggle";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -7%";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +3%";

        "XF86MonBrightnessDown" = "exec ${pkgs.xorg.xbacklight}/bin/xbacklight -dec 7";
        "XF86MonBrightnessUp"   = "exec ${pkgs.xorg.xbacklight}/bin/xbacklight -inc 3";

        "$mod+F11" = "exec compton-trans -c -7";
        "$mod+F12" = "exec compton-trans -c +3";

        "$mod+Return" = "exec ${terminal-at-title-path}/bin/terminal-at-title-path; exec ${i3-set-split-by-size}/bin/i3-set-split-by-size";
        "$mod+Shift+q" = "kill";
        "$mod+d" = "exec ${pkgs.dmenu}/bin/dmenu_run -i";
        "$mod+f" = "exec ${pkgs.i3-easyfocus}/bin/i3-easyfocus";

        # move focus/move hjkl
        "$mod+h" = "focus left;  exec ${center-mouse}/bin/center-mouse";
        "$mod+j" = "focus down;  exec ${center-mouse}/bin/center-mouse";
        "$mod+k" = "focus up;    exec ${center-mouse}/bin/center-mouse";
        "$mod+l" = "focus right; exec ${center-mouse}/bin/center-mouse";

        "$mod+Shift+h" = "move left";
        "$mod+Shift+j" = "move down";
        "$mod+Shift+k" = "move up";
        "$mod+Shift+l" = "move right";

        "$mod+v" = "split v";
        "$mod+b" = "split h";
        "$mod+space" = "fullscreen toggle";

        "$mod+s" = "layout stacking";
        "$mod+w" = "layout tabbed";
        "$mod+e" = "layout toggle split";

        "$mod+Tab" = "[con_mark=f] focus";

        "$mod+Shift+space" = "floating toggle";
        "$mod+Shift+Tab" = "focus mode_toggle";
        "$mod+minus" = "sticky toggle";

        "$mod+a" = "focus parent";
        "$mod+z" = "focus child";

        "$mod+1" = "workspace 1";
        "$mod+2" = "workspace 2";
        "$mod+3" = "workspace 3";
        "$mod+4" = "workspace 4";
        "$mod+5" = "workspace 5";
        "$mod+6" = "workspace 6";
        "$mod+7" = "workspace 7";
        "$mod+8" = "workspace 8";
        "$mod+9" = "workspace 9";

        "$mod+Shift+1" = "move container to workspace 1";
        "$mod+Shift+2" = "move container to workspace 2";
        "$mod+Shift+3" = "move container to workspace 3";
        "$mod+Shift+4" = "move container to workspace 4";
        "$mod+Shift+5" = "move container to workspace 5";
        "$mod+Shift+6" = "move container to workspace 6";
        "$mod+Shift+7" = "move container to workspace 7";
        "$mod+Shift+8" = "move container to workspace 8";
        "$mod+Shift+9" = "move container to workspace 9";

        "$mod+Shift+c" = "reload";
        "$mod+Shift+r" = "restart";

        # resize (also mod + rmb)
        "$mod+Ctrl+Shift+h"  = "resize shrink width  ${resizeSize} px or ${resizeSize} ppt; exec ${i3-set-split-by-size}/bin/i3-set-split-by-size";
        "$mod+Ctrl+Shift+j"  = "resize shrink height ${resizeSize} px or ${resizeSize} ppt; exec ${i3-set-split-by-size}/bin/i3-set-split-by-size";
        "$mod+Ctrl+Shift+k"  = "resize grow   height ${resizeSize} px or ${resizeSize} ppt; exec ${i3-set-split-by-size}/bin/i3-set-split-by-size";
        "$mod+Ctrl+Shift+l"  = "resize grow   width  ${resizeSize} px or ${resizeSize} ppt; exec ${i3-set-split-by-size}/bin/i3-set-split-by-size";
      };
    };
  };
}
