# -------------------------------
#  Powerlevel10k Instant Prompt
# -------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -------------------------------
# 💻 기본 환경 설정
# -------------------------------
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"
export PATH="$HOME/.bin:$PATH"
export EDITOR=nvim
[[ -z "$DISPLAY" ]] && export DISPLAY=:0

# -------------------------------
#  테마 설정
# -------------------------------
ZSH_THEME="powerlevel10k/powerlevel10k"

# -------------------------------
#  플러그인 설정
# -------------------------------
plugins=(
  git
  aliases
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-interactive-cd
  zsh-completions
)

# -------------------------------
#  Oh My Zsh 초기화
# -------------------------------
[[ -d "$ZSH" ]] && source $ZSH/oh-my-zsh.sh

# 🔄 자동완성 초기화
autoload -Uz compinit && compinit

# --- Kubernetes 자동완성 ---
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
  alias k=kubectl
  compdef k=kubectl
fi

# -------------------------------
#  키 바인딩 및 히스토리
# -------------------------------
bindkey '^ ' autosuggest-accept
bindkey -v
HISTFILE=~/.zsh_history

# -------------------------------
#  별칭 설정
# -------------------------------
alias zshconfig="vi ~/.zshrc"
alias refresh='source ~/.zshrc'
alias ohmyzsh="vi ~/.oh-my-zsh"

alias md='mkdir -p'
alias df='df -h'
alias free='free -m'
alias psmem='ps auxf | sort -nr -k 4 | head -5'
alias pscpu='ps auxf | sort -nr -k 3 | head -5'
alias ls='ls --color=auto'
alias lR='ls --color=auto -lahR'
alias cls='clear'
alias c='clear'

alias a=alias
alias ag='alias | grep '
alias hg='history | grep '
alias ha='history -i'
alias h='history -10'
alias gcM='git commit -m'


# -------------------------------
#  Powerlevel10k 설정
# -------------------------------
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# -------------------------------
#  Syntax Highlighting
# -------------------------------
[[ -f $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# -------------------------------
#  LunarVim 설정
# -------------------------------
command -v lvim &>/dev/null && {
  alias vim='lvim'
  alias vi='lvim'
}


