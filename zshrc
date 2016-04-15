# If we can, profile profile profile!
if [ -f ~/.profile ]; then
	. ~/.profile
fi

# The following lines were added by compinstall
zstyle ':completion:*' completer _expand _complete _ignored
zstyle :compinstall filename '/home/tmc/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.zshhist
HISTSIZE=100000
SAVEHIST=1000000
setopt appendhistory autocd beep extendedglob nomatch notify
bindkey -v
# End of lines configured by zsh-newuser-install

# Manually added.

case `uname` in
	Linux)
		alias ls='ls --color=y'
		alias grep='grep --color=always'
		;;
esac

alias l='ls'
alias la='ls -a'
alias ll='l -l'
alias please='sudo'
alias emacs='emacs -nw'
alias irc='mosh arabella tmux attach'
alias mosh='LC_ALL=en_US.UTF-8 mosh'

# Let's colorize our PS1!
autoload -U colors && colors

if [ $(/usr/bin/locale | grep -ic "utf") -gt 0 ]; then
	export PROMPT="%B%(!,%F{red},%F{blue})┌-%f%b%F{yellow}(%T)%f %B%(!,%F{red},%F{green})%n%f%F{black}@%f%(0?,%F{blue},%F{red})%M%f %(!,%F{red},%F{cyan})%~%f%b
%B%(!,%F{red},%F{blue})└%(!,#,»)%f%b "
	export RPROMPT="%(1j,%B%F{yellow}[%j]%f%b,)"
	export PROMPT2="%B%F{green}»%f%b "
else
	export PROMPT="%F{yellow}(%T)%f %B%(!,%F{red},%F{green})%n%f%F{black}@%f%(0?,%F{blue},%F{red})%M%f %(!,%F{red},%F{cyan})%~%f%b
%B%(!,%F{red},%F{blue})%(!,#,>)%f%b "
	export RPROMPT="%(1j,%B%F{yellow}[%j]%f%b,)"
	export PROMPT2="%B%F{green}>%f%b "
fi

# Enable stuff like: http://zsh.sourceforge.net/Intro/intro_6.html#SEC6
DIRSTACKSIZE=8
setopt autopushd pushdminus pushdsilent pushdtohome
alias dh='dirs -v'

### Fish-like syntax highlighting
# Arch way with # pacman -S zsh-syntax-highlighting:
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
#Gentoo way with # layman -a mv; emerge zsh-syntax-highlighting
if [ -f /usr/share/zsh/site-contrib/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
	source /usr/share/zsh/site-contrib/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# I want help!
autoload -U run-help
autoload run-help-git
autoload run-help-svn
autoload run-help-svk
unalias run-help
alias help=run-help

# No delay between install and getting it in my $PATH
setopt nohashdirs

# Easily set a name for a long directory
namedir () { $1=$PWD ;  : ~$1 }

# Stolen from phy1729
# map :h to opening vim's help in fullscreen
alias :h='noglob :h-helper'
function :h-helper () { vim +"h" +"h $1" +only +'nnoremap q :q!<CR>'; }
