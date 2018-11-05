{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix # hardware scan results
      "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
    ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/sda3";
      preLVM = true;
    }
  ];

  # networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  time.timeZone = "Europe/Zagreb";

  # services.openssh.enable = true;

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.nixosManual.showManual = true;

  services.xserver.enable = true;
  # services.xserver.layout = "us";
  services.xserver.xkbOptions = "ctrl:nocaps";

  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
    tapButtons = false;
    additionalOptions = ''
      Option "TapButton3" "2"
    '';
  };

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xmodmap}/bin/xmodmap ~/.Xmodmap
    ${pkgs.xlibs.xset}/bin/xset r rate 200 60  # keyboard repeat rate

    while true; do ${pkgs.feh}/bin/feh -z --bg-fill ~/Downloads/Wallpapers;
      sleep $((5*60)); done &
  '';

  users.users.radivarig = {
    isNormalUser = true; # set some defaults
    extraGroups = [ "wheel" ];
    uid = 1000;
    shell = pkgs.zsh;
  };

  home-manager.users.radivarig = {
    programs.git = {
      enable = true;
      userName = "Radivarig";
      userEmail = "reslav.hollos@gmail.com";
    };

    home.packages = with pkgs; [
      trash-cli
      source-code-pro
      vscode

      xorg.xev
      xorg.xmodmap
      feh
    ];

    # bind Alt_R + hjkl to arrows
    home.file.".Xmodmap".text = ''
      ! unbind Alt_R
      keycode 108 = NoSymbol NoSymbol
      keycode 108 = Mode_switch

      keysym h = h H Left NoSymbol NoSymbol NoSymbol
      keysym j = j J Down NoSymbol NoSymbol NoSymbol
      keysym k = k K Up NoSymbol NoSymbol NoSymbol
      keysym l = l L Right NoSymbol lstroke Lstroke
    '';

    programs.zsh = {
      initExtra = ''
        # use array since no word split in zsh
        export EDITOR=(emacs -nw)

        # make cd clear and ls
        cd() { builtin cd "$@" && clear && ls --group-directories-first ; }
      '';

      shellAliases = {
        edit = "$EDITOR";
        mkdir = "mkdir -pv"; # create parent
        del = "trash-put";

        # add prompt
        mv = "mv -i";
        cp = "cp -i";
        rm = "rm -i";
      };
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "af-magic";
      };
    };

    programs.emacs = {
      enable = true;
    };

    programs.chromium.enable = true;

    xresources.properties = {
      "xterm*background" = "black";
      "xterm*foreground" = "lightgray";
      "xterm*metaSendsEscape" = "true";
      "xterm*selectToClipboard" = "true";
      "xterm*cursorBlink" = "1";
      "xterm*titeInhibit" = "true";
    };

    xsession.enable = true;
    xsession.windowManager.i3 = rec {
      enable = true;
      config.modifier = "Mod4";
      config.keybindings = let
        mod = config.modifier;
        left = "h"; down = "j"; up = "k"; right = "l";
        resizeSmall = "1"; resizeBig = "5";
      in {
        "${mod}+Return" = "exec i3-sensible-terminal";
        "${mod}+Shift+q" = "kill";
        "${mod}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run -i";

        "${mod}+${left}"  = "focus left";
        "${mod}+${down}"  = "focus down";
        "${mod}+${up}"    = "focus up";
        "${mod}+${right}" = "focus right";

        "${mod}+Shift+${left}"  = "move left";
        "${mod}+Shift+${down}"  = "move down";
        "${mod}+Shift+${up}"    = "move up";
        "${mod}+Shift+${right}" = "move right";

        "${mod}+v" = "split toggle";
        "${mod}+f" = "fullscreen toggle";

        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";

        "${mod}+Shift+space" = "floating toggle";
        "${mod}+tab" = "focus mode_toggle";
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
        "${mod}+Ctrl+${left}"  = "resize shrink width  ${resizeSmall} px or ${resizeSmall} ppt";
        "${mod}+Ctrl+${down}"  = "resize shrink height ${resizeSmall} px or ${resizeSmall} ppt";
        "${mod}+Ctrl+${up}"    = "resize grow   height ${resizeSmall} px or ${resizeSmall} ppt";
        "${mod}+Ctrl+${right}" = "resize grow   width  ${resizeSmall} px or ${resizeSmall} ppt";

        "${mod}+Ctrl+Shift+${left}"  = "resize shrink width  ${resizeBig} px or ${resizeBig} ppt";
        "${mod}+Ctrl+Shift+${down}"  = "resize shrink height ${resizeBig} px or ${resizeBig} ppt";
        "${mod}+Ctrl+Shift+${up}"    = "resize grow   height ${resizeBig} px or ${resizeBig} ppt";
        "${mod}+Ctrl+Shift+${right}" = "resize grow   width  ${resizeBig} px or ${resizeBig} ppt";
      };
    };

  };

  # change ONLY after NixOS release notes say so (db servers can break)
  system.stateVersion = "18.09"; # Did you read the comment?

}
