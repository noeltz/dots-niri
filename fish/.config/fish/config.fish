if status is-interactive
   set -g fish_greeting ""
   fastfetch
end

# Append common directories for executable files to $PATH
fish_add_path ~/.local/bin ~/.cargo/bin ~/Applications/depot_tools

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

# Format man pages
set -x MANROFFOPT "-c"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

# General aliases
alias tree='eza --icons --tree --group-directories-first'
alias bat='bat --color=always'
alias sup='sudo pacman'

# Replace ls with eza
alias ls='eza -al --color=always --group-directories-first --icons=always' # preferred listing
alias la='eza -a --color=always --group-directories-first --icons=always'  # all files and dirs
alias ll='eza -l --color=always --group-directories-first --icons=always'  # long format
alias lt='eza -aT --color=always --group-directories-first --icons=always' # tree listing
alias l.="eza -a | grep -e '^\.'"                                     # show only dotfiles

# Common use
alias grubup="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias wget='wget -c '
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias hw='hwinfo --short'                                   # Hardware Info
alias big="expac -H M '%m\t%n' | sort -h | nl"              # Sort installed packages according to size in MB
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l'          # List amount of -git packages
alias update='sudo cachyos-rate-mirrors && sudo pacman -Syu'

# Get fastest mirrors
alias mirror="sudo cachyos-rate-mirrors"

# Help people new to Arch
alias apt='man pacman'
alias apt-get='man pacman'
alias tb='nc termbin.com 9999'

# Cleanup orphaned packages
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# Recent installed packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

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

# init starship
starship init fish | source
