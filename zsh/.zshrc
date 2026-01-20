# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit ice depth=1; zinit light romkatv/powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load Completions
autoload -Uz compinit
compinit -u

bindkey -v
export KEYTIMEOUT=1

# History size 
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
unsetopt BANG_HIST

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='eza'
alias v='nvim'
alias t='tmux'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tls='tmux ls'
alias trs='tmux rename-session -t'
alias h='history'
alias cd='z'
alias lgit='lazygit'
alias wlcp='wl-copy'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.npm-global/bin"
# export PATH="$HOME/.venv/nvim/bin:$PATH"
export BROWSER=zen-browser
export EDITOR=nvim
export VISUAL=nvim

export __GL_THREADED_OPTIMIZATIONS=0
export __GL_SYNC_TO_VBLANK=0
eval "$(direnv hook zsh)"
