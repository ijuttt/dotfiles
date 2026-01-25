# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# ─────────────────────────────────────────────────────────────
# Powerlevel10k Instant Prompt
# ─────────────────────────────────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
zinit light Aloxaf/fzf-tab
zinit ice depth=1
zinit light romkatv/powerlevel10k

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ─────────────────────────────────────────────────────────────
# Completion System
# ─────────────────────────────────────────────────────────────
autoload -Uz compinit
compinit -u

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
alias trs='tmux rename-session -t'
alias tkill='tmux kill-server'
alias h='history'
alias cd='z'
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
eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"
eval "$(direnv hook zsh)"

# ─────────────────────────────────────────────────────────────
# Environment Variables
# ─────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

export EDITOR=nvim
export VISUAL=nvim
export BROWSER=zen-browser

export __GL_THREADED_OPTIMIZATIONS=0
export __GL_SYNC_TO_VBLANK=0
