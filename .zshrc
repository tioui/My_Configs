# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=100000
setopt appendhistory extendedglob notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/louis/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

PS1="%F{green}%n@%m:%F{blue}%~%f%# "

. /etc/zsh_command_not_found

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

typeset -gx ISE_EIFFEL=/usr/local/Eiffel_18.07
typeset -gx ISE_PLATFORM=linux-x86-64
typeset -gx PATH=$PATH:$ISE_EIFFEL/studio/spec/$ISE_PLATFORM/bin
typeset -gx PATH=$PATH:$ISE_EIFFEL/esbuilder/spec/$ISE_PLATFORM/bin
typeset -gx FCEUX_BP_SRC=/home/louis/prog/fceux-bp
typeset -gx DEBFULLNAME="Louis M"
typeset -gx DEBEMAIL="linux@tioui.com"
typeset -gx MYSQLINC=/usr/include/mysql
typeset -gx MYSQLLIB=/usr/lib/x86_64-linux-gnu

alias vimeiffel="vim.gtk-py2 -c EOpen"

typeset -gx PATH=$PATH:/home/louis/.local/bin
