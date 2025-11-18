function fdir -d "Pick directory → cd into it"
    set -l dir (fd --type d -H | fzf --preview='eza -lha --icons --group-directories-first --level 3 {}')
    test -n "$dir"; and cd $dir
end
