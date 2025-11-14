function fcode -d "Pick directory → open in VS Code"
    set -l dir (fd --type d -H | fzf --preview='eza --tree --icons --color=always --group-directories-first --level 3 {}')
    test -n "$dir"; and code $dir;
end
