function fish_right_prompt
    set -l t (date '+%T')               # HH:MM:SS
    set -l dur (_omp_since_start)

    set -l dur_str ''
    test $dur -gt 2000; and set dur_str (string trim -r -c 0 (math -s0 "$dur / 1000"))ms

    set -l out ''
    test -n "$dur_str"; and set out "$dur_str "
    set out "$out$t"

    set_color $seg_git_fg # Polar Night 4 (muted)
    echo -n $out
    set_color normal
end
