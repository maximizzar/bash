# ls command (I use eza, an ls alt)
alias ls='eza --all        --grid --git --time-style iso'
alias la='eza --all        --grid --git --time-style iso'
alias ll='eza --all --long --grid --git --time-style iso'
alias lt='eza --all --long        --git --time-style iso --tree'

# cd command behavior
alias ..='cd ..'

up() {
    cd $(printf "%0.s../" $(seq 1 "$1"))
}

# Create parent directories on demand
alias mkdir='mkdir -pv'

#Colorize diff output
alias diff='colordiff'

# Mount command Pretty and readable
alias mount='mount | column --table --keep-empty-lines'

# date and time
alias now='date +"%T"'
alias datetime='date +"%d-%m-%Y: %T"'

# networking
alias ports='ss -tupln'
alias ipa='ip address show'
alias ipas='ip address show'

alias wget='wget --no-verbose --continue --show-progress --no-dns-cache --xattr --content-disposition'

# safety nets
alias rm='rm -I --preserve-root'

# confirmation #
alias mv='mv --interactive'
alias cp='cp --archive --interactive --update'
alias ln='ln --interactive --verbose'

# Parenting changing perms on / #
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# neofetch defaults
alias neofetch='neofetch --title_fqdn on --speed_shorthand on --cpu_temp C --memory_percent on --config none --no_config'

# fzf defaults
alias fzf='fzf --color 16'

# yt-dlp defaults
alias yt-dlp='yt-dlp --no-restrict-filenames --mtime --quiet --progress --prefer-free-formats  --write-subs --netrc --audio-quality 0 --embed-metadata --embed-thumbnail --xattrs'

# gallery-dl defaults
alias gallery-dl='gallery-dl --mtime date'