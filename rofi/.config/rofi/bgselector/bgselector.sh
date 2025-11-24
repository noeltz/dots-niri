#!/usr/bin/env bash

# Set dir varialable
wall_dir="$HOME/.local/share/wallpaper"
cacheDir="$HOME/.cache/thumbnails/bgselector"

# Create cache dir if not exists
[ -d "$cacheDir" ] || mkdir -p "$cacheDir"

# Rofi command
rofi_command="rofi -i -show -dmenu -config "$HOME/.config/rofi/bgselector/style.rasi"

# Detect number of cores and set a sensible number of jobs
get_optimal_jobs() {
    local cores=$(nproc)
    ((cores <= 2)) && echo 2 || echo $(((cores > 4) ? 4 : cores - 1))
}

PARALLEL_JOBS=$(get_optimal_jobs)

process_image() {
    local imagen="$1"
    local nombre_archivo=$(basename "$imagen")
    local cache_file="${cacheDir}/${nombre_archivo}"
    local md5_file="${cacheDir}/.${nombre_archivo}.md5"
    local lock_file="${cacheDir}/.lock_${nombre_archivo}"

    local current_md5=$(xxh64sum "$imagen" | cut -d' ' -f1)

    (
        flock -x 200
        if [ ! -f "$cache_file" ] || [ ! -f "$md5_file" ] || [ "$current_md5" != "$(cat "$md5_file" 2>/dev/null)" ]; then
            magick "$imagen" -resize 500x500^ -gravity center -extent 500x500 "$cache_file"
            echo "$current_md5" >"$md5_file"
        fi
        # Clean the lock file after processing
        rm -f "$lock_file"
    ) 200>"$lock_file"
}

# Export variables & functions
export -f process_image
export wall_dir cacheDir

# Clean old locks before starting
rm -f "${cacheDir}"/.lock_* 2>/dev/null || true

# Process files in parallel
find "$wall_dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) -print0 |
    xargs -0 -P "$PARALLEL_JOBS" -I {} bash -c 'process_image "{}"'

# Clean orphaned cache files and their locks
for cached in "$cacheDir"/*; do
    [ -f "$cached" ] || continue
    original="${wall_dir}/$(basename "$cached")"
    if [ ! -f "$original" ]; then
        nombre_archivo=$(basename "$cached")
        rm -f "$cached" \
            "${cacheDir}/.${nombre_archivo}.md5" \
            "${cacheDir}/.lock_${nombre_archivo}"
    fi
done

# Clean any remaining lock files
rm -f "${cacheDir}"/.lock_* 2>/dev/null || true

# Check if rofi is already running
if pidof rofi >/dev/null; then
    pkill rofi
fi

# Launch rofi
wall_selection=$(find "${wall_dir}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) -print0 |
    xargs -0 basename -a |
    LC_ALL=C sort -V |
    while IFS= read -r A; do
        if [[ "$A" =~ \.gif$ ]]; then
            printf "%s\n" "$A" # Handle gifs by showing only file name
        else
            printf '%s\x00icon\x1f%s/%s\n' "$A" "${cacheDir}" "$A" # Non-gif files with icon convention
        fi
    done | $rofi_command)

# Exit immediately if there is no selection
[[ -z "${wall_selection}" ]] && exit 0

# Full wallpaper path
wallpaper_path="${wall_dir}/${wall_selection}"

# Apply wallpaper
if [ -n "$wall_selection" ]; then
    selected_path="${wallpaper_path}"
    if [ -f "$selected_path" ]; then
        swww img "$selected_path" -t fade --transition-duration 1 --transition-fps 60 &
        sleep 0.2
        "$HOME/.config/scripts/theme-sync.sh" &
        wait
    fi
fi


