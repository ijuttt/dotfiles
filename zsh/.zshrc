# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# ─────────────────────────────────────────────────────────────
# Powerlevel10k Instant Prompt (DISABLED - using Starship)
# ─────────────────────────────────────────────────────────────
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# ─────────────────────────────────────────────────────────────
# Zinit (Plugin Manager)
# ─────────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"

# ─────────────────────────────────────────────────────────────
# Plugins
# ─────────────────────────────────────────────────────────────
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit ice wait lucid
zinit light Aloxaf/fzf-tab
# Powerlevel10k (DISABLED - using Starship)
# zinit ice depth=1
# zinit light romkatv/powerlevel10k
# [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ─────────────────────────────────────────────────────────────
# Completion System
# ─────────────────────────────────────────────────────────────
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# ─────────────────────────────────────────────────────────────
# Keybind & Shell Behavior 
# ─────────────────────────────────────────────────────────────
bindkey -v
KEYTIMEOUT=1

# ─────────────────────────────────────────────────────────────
# History
# ─────────────────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
setopt appendhistory
setopt sharehistory
unsetopt BANG_HIST

# ─────────────────────────────────────────────────────────────
# Aliases
# ─────────────────────────────────────────────────────────────
alias ls='eza'
alias v='nvim'
alias t='tmux'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tls='tmux ls'
alias tkill='tmux kill-server'
alias trs='tmux rename-session -t'
alias h='history'
alias lgit='lazygit'
alias wlcp='wl-copy'
alias man='batman'
alias diff='batdiff'
alias cat='bat --paging=never'
alias less='bat --paging=always'

# ─────────────────────────────────────────────────────────────
# Shell Integrations
# ─────────────────────────────────────────────────────────────
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# ─────────────────────────────────────────────────────────────
# Environment Variables
# ─────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

export EDITOR=nvim
export VISUAL=nvim
export BROWSER=xdg-open

export __GL_THREADED_OPTIMIZATIONS=0
export __GL_SYNC_TO_VBLANK=0

# ─────────────────────────────────────────────────────────────
# Starship Prompt
# ─────────────────────────────────────────────────────────────
eval "$(starship init zsh)"
