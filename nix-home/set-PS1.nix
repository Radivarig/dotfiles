''
# TODO: check if git exists
get_git_branch(){ git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/';}
get_git_dirty(){ [[ ! -z "$(git status --porcelain 2> /dev/null)" ]] && echo "☢";}
get_shell_name(){ [[ ! -z $name ]] && echo "$name";}

append_space_if_defined(){ local str=$(echo "$*" | awk '{$1=$1};1'); echo "''${str:+$str }";}

# prompt string
PS1='\
\[\e[33m\]`append_space_if_defined $(get_shell_name)`\
\[\e[32m\]`append_space_if_defined $(get_git_branch)`\
\[\e[93m\]`append_space_if_defined $(get_git_dirty)`\
\[\e[90m\]λ \
\[\e[00m\]'
''
