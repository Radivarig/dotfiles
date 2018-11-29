{ ... }: {
  xresources.properties = {
    "xterm*background" = "black";
    "xterm*foreground" = "white";
    "xterm*metaSendsEscape" = "true";
    "xterm*selectToClipboard" = "true";
    "xterm*cursorBlink" = "1";
    "xterm*titeInhibit" = "true";
    "xterm*translations" = '' #override \n\
      Ctrl <Key> minus: smaller-vt-font() \n\
      Ctrl <Key> plus: larger-vt-font()
    '';
  };
}
