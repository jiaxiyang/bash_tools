#!/bin/bash
set -e

main() {
    cp .fzf/fzf .fzf/bin/
    cp -r .fzf ~/
    mkdir -p ~/.bin
    cp -r * ~/.bin
    cp .tmux.conf ~/
    (cd ~/.fzf && ./install)

    (install_git_alias)
    (maybe_config_bashrc)
}

run() {
    info "$*"
    eval "$*"
}

info() {
    echo "info $*"
}

install_git_alias() {
    info installing git alias
    ## setup git alias
    git config --global color.ui auto
    git config --global alias.l 'log --graph --decorate --full-diff'
    git config --global alias.ll 'log --graph --decorate --full-diff --stat'
    git config --global alias.d 'diff --ignore-space-at-eol --ignore-all-space --ignore-space-change --color=always'
    git config --global alias.la 'log --graph --decorate --all'
    git config --global alias.s 'status --untracked-files'
    git config --global alias.a 'add -A -p'
    git config --global alias.rvs 'remote -v show'
    git config --global alias.p 'pull --rebase'
    git config --global alias.m 'merge --ff-only'
    git config --global alias.f 'fetch --all --prune'
    git config --global alias.c 'commit --verbose'
    git config --global alias.mr "mr = !sh -c 'git fetch $1 merge-requests/$2/head:mr-$1-$2 && git checkout mr-$1-$2' -"
    git config --global push.default simple
    git config --global core.excludesfile ~/.gitignore
}

maybe_config_bashrc() {

    bashrc_config=$(
        cat <<EOF
HISTSIZE=10000000
HISTFILESIZE=10000000
HISTCONTROL=ignoreboth:ignoredups:erasedup
#PROMPT_COMMAND='history -a;history -c;history -r'
[ -f \$HOME/.fzf.bash ] && source \$HOME/.fzf.bash
[ -f \$HOME/.bin/z.lua ] && eval "\$(lua \$HOME/.bin/z.lua --init bash)" && alias zh='z -I -t .'
export PS1='% '
export PS1='\u@\h:\W% '
export LESS=XR
test -t 1 && stty -ixon # set it only for non-tty
alias gl='global --path-style=through --result=grep --color=always'
alias g=git
alias cd='cd -P'
alias fd='/home/xiyang/.bin/fd'
alias ag='/home/xiyang/.bin/ag'
alias rg='/home/xiyang/.bin/rg'
alias b='/home/xiyang/.bin/bat'
alias bat='/home/xiyang/.bin/bat'
alias d='/home/xiyang/.bin/d.sh'
alias hexyl='/home/xiyang/.bin/hexyl'
alias exa='/home/xiyang/.bin/exa'
alias nnn='/home/xiyang/.bin/nnn'
alias em='emacs -nw'
alias zh='z -I -t .'
alias shfmt='/home/xiyang/.bin/shfmt'
alias tmux='/home/xiyang/.bin/tmux'
alias put='/home/xiyang/.bin/put.sh'
alias get='/home/xiyang/.bin/get.sh'
alias get-list='/home/xiyang/.bin/get-list.sh'
alias get-list-all='/home/xiyang/.bin/get-list-all.sh'
alias gls='/home/xiyang/.bin/get-ls.sh'
function loop ()
{
    eval "\$@";
    while sleep 1; do
        eval "\$@";
    done
}
function title() {
  echo -ne "\033]0;"\$1"\007"
}

EOF
    )
    old_bash_config_md5sum=$(cat ~/.bashrc | awk ' />>> jxy/ {d = 1;next;}  /<<< jxy/{d=0;next}  d== 1 {print}' | md5sum)
    this_bashrc_config_md5sum=$(echo "$bashrc_config" | md5sum)
    if [ x"$old_bash_config_md5sum" == x"$this_bashrc_config_md5sum" ]; then
        return
    fi
    empty_md5sum='d41d8cd98f00b204e9800998ecf8427e  -'
    if [ x"$old_bash_config_md5sum" == x"$empty_md5sum" ]; then
        (
            echo "# >>> jxy bashrc settings"
            echo "$bashrc_config"
            echo "# <<< jxy bashrc settings"
        ) >>$HOME/.bashrc
 else
        begin=$(cat ~/.bashrc | awk 'd==0 {print} />>> jxy/ {exit;}')
        after=$(cat ~/.bashrc | awk '/<<< jxy/{d=1;} d==1 {print}')
        (
            echo "$begin"
            echo "$bashrc_config"
            echo "$after"
        ) >$HOME/.bashrc
    fi
}

main


