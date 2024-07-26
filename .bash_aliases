# list short
alias ls='eza --long --grid --across --dereference --all --smart-group --numeric --time-style '+%Y-%m-%d'       --no-permissions --octal-permissions'
# list alt
alias la='eza --long --grid --across --dereference --all --smart-group --mounts --numeric --time-style long-iso'
# list long
alias ll='eza --long        --across --dereference --all --smart-group --mounts           --time-style long-iso --no-permissions --octal-permissions --git --git-repos --extended --context'

# list tree
lt() {
        if [ -z "$1" ]; then
                eza --tree --all
        else
                eza --tree --all --level "$1"
        fi
}

# cd command behavior
alias ..='cd ..'

up() {
    cd $(printf "%0.s../" $(seq 1 "$1"))
}

# Create parent directories on demand
alias mkdir='mkdir -pv'

# Colorize diff output
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

alias wget='wget --no-verbose --continue --show-progress --no-dns-cache --content-disposition'

# safety nets
alias rm='rm -I --preserve-root'

# confirmation
alias mv='mv --interactive'
alias cp='cp --archive --interactive --update'
alias ln='ln --interactive --verbose'

# Parenting changing perms on
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# neofetch defaults
alias neofetch='neofetch --title_fqdn on --speed_shorthand on --cpu_temp C --memory_percent on --config none --no_config'

# fzf defaults
alias fzf='fzf --color 16'

# yt-dlp defaults
alias yt-dlp='           yt-dlp --no-restrict-filenames --mtime --quiet --progress --prefer-free-formats --write-subs --audio-quality 0 --embed-metadata --embed-thumbnail'
alias yt-dlp-adn='       yt-dlp --no-restrict-filenames --mtime --quiet --progress --prefer-free-formats --write-subs --audio-quality 0 --embed-metadata --embed-thumbnail --config-locations ~/.yt-dlp/animationdigitalnetwork.conf'
alias yt-dlp-hypnotube=' yt-dlp --no-restrict-filenames --mtime --quiet --progress --prefer-free-formats --write-subs --audio-quality 0 --embed-metadata --embed-thumbnail --config-locations ~/.yt-dlp/hypnotube.conf'
alias yt-dlp-pornhub='   yt-dlp --no-restrict-filenames --mtime --quiet --progress --prefer-free-formats --write-subs --audio-quality 0 --embed-metadata --embed-thumbnail --config-locations ~/.yt-dlp/pornhub.conf'

# gallery-dl defaults
alias gallery-dl='gallery-dl --mtime date'

# radeontop defaults
alias radeontop='radeontop --color --ticks 180 --transparency'

# shellcheck with color
alias shellcheck='shellcheck --color=always'

# ps aliases
alias ps='ps -lt'
alias pst='ps axjf'
