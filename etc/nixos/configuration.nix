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
    xsession.windowManager.i3 = {
      enable = true;
      config.modifier = "Mod4";
    };

  };

  # change ONLY after NixOS release notes say so (db servers can break)
  system.stateVersion = "18.09"; # Did you read the comment?

}
