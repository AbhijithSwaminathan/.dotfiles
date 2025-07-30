# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we wnat to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
# Paths
export PATH="$HOME/.local/bin:$PATH"

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light ALoxaf/fzf-tab
zinit light MichaelAquilina/zsh-you-should-use

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::ubuntu
zinit snippet OMZP::command-not-found
zinit snippet OMZP::sudo
zinit snippet OMZP::npm
zinit snippet OMZP::docker-compose
zinit snippet OMZP::docker
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::helm
zinit snippet OMZP::python
zinit snippet OMZP::pip
zinit snippet OMZP::node
zinit snippet OMZP::rust
zinit snippet OMZP::golang
zinit snippet OMZP::gh

# Load completions
autoload -U compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# FZF Theme

export FZF_DEFAULT_OPTS=" \
 --color=bg:#051519,fg:#b8b1a9,hl:#1a8d63\
 --color=bg+:#3d3d3d,fg+:#b8b1a9,hl+:#2fc859\
 --color=info:#39a7a2,border:#8ed0ce,prompt:#92d3a2\
 --color=pointer:#051519,marker:#fb3d66,spinner:#fb3d66,header:#f8818e"

# FZF Keybindings
export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git --exclude node_modules'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --strip-cwd-prefix --exclude .git --exclude node_modules'
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons=always {} | head -200'"

# FZF Function

_fzf_compgen_path() {
	fd --hidden --exclude .git node_modules . "$1"
}

_fzf_compgen_dir() {
	fd --type d --hidden --exclude .git node_modules . "$1"
}
# Advance customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the argument to fzf
_fzf_comprun(){
	local command=$1
	shift

	case "$command" in
		cd)	fd --preview 'eza --tree --color=always --icons=always {} | head -200' "$@" ;;
		export|unset)	fd --preview "eval 'echo \$' {}"	"$@" ;;
		ssh)	fd --preview 'dig {}'	"$@" 	;;
		*)	fd --preview 'bat -n --color=always --line-range :500 {}'	"$@"	;;
	esac
}

source $HOME/.config/fzf-git.sh/fzf-git.sh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
alias tree='eza --tree --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
alias leetcode='python3 create_leetcode.py'
alias fd=fdfind
alias cat=bat


# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# thefuck alias
eval $(thefuck --alias)
eval $(thefuck --alias fk)
eval $(thefuck --alias shit)
eval $(thefuck --alias ohno)

#pfetch configs
PF_INFO="ascii title os kernel uptime memory shell"
PF_COL1=3
PF_COL2=7
PF_COL3=3

# Bat (better cat) configurations
export BAT_THEME=tokyonight_night

# PATHS
export PATH=$PATH:/usr/local/go/bin
export PATH="$HOME/.cargo/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

## Cowsay and pfetch
fortune -s | cowsay -f tux | lolcrab --custom "#fe8019,#fabd2f,#fbf1c7"  && pfetch