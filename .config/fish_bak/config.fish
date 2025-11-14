if status is-interactive
   set -g fish_greeting ""	
   fastfetch
end

# Variables
set -gx MICRO_TRUECOLOR 1

# FZF Default Style
set -gx FZF_DEFAULT_OPTS "\
   --color=bg+:#313244,bg:#000000,spinner:#F5E0DC,hl:#F38BA8 \
   --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
   --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#FFFFFF,hl+:#F38BA8 \
   --color=selected-bg:#45475A \
   --color=border:#6C7086,label:#CDD6F4 \
   --style full"
   
# General aliases
alias ls='eza --icons -lha --group-directories-first'
alias tree='eza --icons --tree --group-directories-first'
alias bat='bat --color=always'
alias sup='sudo pacman'

# Git aliases
alias gini='git init'
alias gend='rm -r .git'
alias gclo='git clone'
alias gadd='git add'
alias gcom='git commit -m'
alias gpsh='git push'
alias gsts='git status'
alias gcho='git checkout -b'
alias gpll='git pull'
alias glog='git log'

# Docker aliases
alias lzd='lazydocker'
alias dps='docker ps'
alias dpull='docker pull'
alias drun='docker run'

# Git aliases TODO
alias lzg='lazygit'
