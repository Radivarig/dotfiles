{ pkgs, ... }:
{
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
    keysym h = h H Left Left
    keysym j = j J Down Down
    keysym k = k K Up Up
    keysym l = l L Right Right

    keysym g = g G Home Home
    keysym semicolon = semicolon colon End End

    ! keypad numbers for mousekeys
    keysym y = y Y KP_4 KP_4
    keysym u = u U KP_2 KP_2
    keysym i = i I KP_8 KP_8
    keysym o = o O KP_6 KP_6

    ! keysym 8 = 8 asterisk Pointer_Button5 Pointer_Button5
    ! keysym 9 = 9 parenleft Pointer_Button4 Pointer_Button4
    keysym 0 = 0 parenright Pointer_Button1 Pointer_Button1
    keysym minus = minus underscore Pointer_Button3 Pointer_Button3
    keysym equal = equal plus Pointer_Button2 Pointer_Button2
  '';

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

  home.file.".apply_keyboard_settings".text = ''
    ${pkgs.xorg.xinput}/bin/xinput disable $(${pkgs.xorg.xinput}/bin/xinput | grep -i touchpad | grep -oP '.*id=\K\d+')

    # compose [release + symbol + letter]: (/ đ) (< ž) (' ć)
    setxkbmap -model pc104 -layout us -option "compose:rctrl"
    ${pkgs.xorg.xmodmap}/bin/xmodmap ~/.Xmodmap
    ${pkgs.xcape}/bin/xcape -e 'Control_L=Escape' # trigger escape on single lctrl
    ${pkgs.xbindkeys}/bin/xbindkeys -f ~/.xbindkeysrc

    ${pkgs.xkbset}/bin/xkbset r rate 200 20 # keyboard repeat rate
    ${pkgs.xkbset}/bin/xkbset m # enable mousekeys
    # xkbset ma [delay] [interval] [time to max] [max speed] [curve]
    ${pkgs.xkbset}/bin/xkbset ma 1 15 40 30 20 # mousekeys accelleration
    # TODO: why this stops working?? xkbset q | grep "Mouse Keys" shows "Mouse Keys: On"
    while true; do ${pkgs.xkbset}/bin/xkbset m; sleep 3; done
  '';

  xsession.initExtra = ''
    source ./.apply_keyboard_settings &
  '';
}
