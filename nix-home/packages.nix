{pkgs, ...}: with pkgs;
{
  home.packages = [
    # media
    pavucontrol
    krita
    unstable.blender
    unstable.spotify
    vlc
    unstable.mps-youtube # not working

    freemind # mind maps
    libreoffice
    evince # pdf

    # audio
    ardour
    audio-recorder
    # qjackctl jack2
    guitarix
    gxplugins-lv2

    irssi
    zoom-us
    hexchat
    # viber

    ranger
    highlight

    # tools
    trash-cli
    pciutils # lspci setpci
    qdirstat # # disk size gui
    openvpn # sudo openvpn --config conf.ovpn
    ntfs3g # sudo ntfs-3g -o remove_hiberfile /dev/sdXY ~/mount
    wirelesstools
    inotify-tools
    tldr
    wget
    zip
    unzip
    lsof
    htop
    arandr # xrandr gui
    xorg.xhost # xhost +local: # allow connections to display
    xorg.xkill # click kill x window
    xorg.xev # evaluate

    # hicolor-icon-theme # fallback icons for freedesktop.org
    source-code-pro # font
  ];
}