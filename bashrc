#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '

alias ls='ls --color=auto'
alias grep='grep --colour=auto'

export EDITOR='vim'

alias mcs='apvlv Books/mcs.pdf'
