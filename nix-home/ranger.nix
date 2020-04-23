{pkgs, ...}:
let
  ranger-cd =builtins.replaceStrings ["/usr/bin/ranger"] ["${pkgs.ranger}/bin/ranger"]
    (builtins.readFile "${pkgs.ranger.src}/examples/shell_automatic_cd.sh");
in
{
  programs.bash.initExtra = ''
    ${ranger-cd} # also does: bind '"\C-o":"ranger-cd\C-m"'
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

}

