function fish_prompt

    set -l last_status $status

    set -l seg_user_bg  "#89b4fa"   # blue
    set -l seg_user_fg  "#11111b"   # text
    set -l seg_host_bg  "#fab387"   # orange
    set -l seg_host_fg  "#11111b"   # text
    set -l seg_pwd_bg   "#f9e2af"   # yelow
    set -l seg_pwd_fg   "#11111b"   # text
    set -l seg_git_bg   "#a6e3a1"   # green
    set -l seg_git_fg   "#11111b"   # text
    set -l seg_err_bg   "#f38ba8"   # red
    set -l seg_err_fg   "#181825"   # text
    set -l seg_pmt_bg   "#090909"   # mantle
    set -l seg_pmt_fg   "#cdd6f4"   # yellow

    # 1. USER and HOST
    set_color -b $seg_user_bg $seg_user_fg
    printf '  %s ' (whoami)
    set_color -b $seg_host_bg $seg_host_fg
    printf '  %s ' (prompt_hostname)

    # 2. Current Working Directory (CWD)
    set_color -b $seg_pwd_bg $seg_pwd_fg
    printf '  %s ' (pwd)

    # 3. Git (if whe're inside a repository)
    set -l git_info (fish_git_prompt)
    if test -n "$git_info"
        set_color -b $seg_git_bg $seg_git_fg
        printf ' 󰊤%s  ' $git_info
    end

    # 4. Exit-code (on error)
    if test $last_status -ne 0
        set_color -b $seg_err_bg $seg_err_fg
        printf '  [%s] ' $last_status
    end

    # 5. Prompt 
    set_color -b $seg_pmt_bg $seg_pmt_fg
    set_color red
    printf '\n❯'
    set_color yellow
    printf '❯'
    set_color green
    printf '❯ '
    set_color white

    # reset stopwatch
    set -g __cmd_start (date '+%s%3N')
end

set -g __cmd_start (date '+%s%3N')

function _omp_since_start
    set -l now (date '+%s%3N')
    echo (math -s0 "$now - $__cmd_start")
end
