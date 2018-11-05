# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
    ];

  nixpkgs.config = {
    allowUnfree = true;
    # more stuff
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/sda3";
      preLVM = true;
    }
  ];
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  time.timeZone = "Europe/Zagreb";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   wget vim
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.nixosManual.showManual = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;
  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
    tapButtons = false;
    additionalOptions = ''
      Option "TapButton3" "2"
    '';
  };

  services.xserver.xkbOptions = "ctrl:nocaps";

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xmodmap}/bin/xmodmap ~/.Xmodmap
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
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

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?

}
