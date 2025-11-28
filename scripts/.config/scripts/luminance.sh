#!/bin/bash
#
# Luminance Theme Selector Script (Noeltz Edition)
# Usage: ./get_theme_for_wallpaper.sh /path/to/wallpaper.jpg
# Output: DARK or LIGHT (only)

# The threshold (0-255 scale) to determine brightness.
# If luminance > 128, the image is considered "bright," recommending a DARK GUI theme for contrast.
LUMINANCE_THRESHOLD=128

image_path="$1"

# Check if the image path is provided and the file exists.
if [ -z "$image_path" ] || [ ! -f "$image_path" ]; then
    echo "Error: Image path is missing or file not found: $image_path" >&2
    exit 1
fi

# 1. Get raw mean pixel value (0-65535) from ImageMagick.
# Redirecting stderr (2>/dev/null) to suppress ImageMagick warnings/errors.
raw_mean_luminance=$(/usr/bin/identify -format "%[mean]" "$image_path" 2>/dev/null | tr -d '[:alpha:]')

if [ -z "$raw_mean_luminance" ]; then
    echo "Error: Could not retrieve luminance data from ImageMagick." >&2
    exit 1
fi

# 2. Normalize the raw mean to the 0-255 scale using simple division.
# Using 'bc' for precise arithmetic and scale=0 for integer output.
normalized_mean_luminance=$(echo "scale=0; ($raw_mean_luminance / 256)" | bc)

# 3. Decision Logic: Recommend DARK theme if the image is BRIGHT, and LIGHT if it is DARK.
if [ "$normalized_mean_luminance" -gt "$LUMINANCE_THRESHOLD" ]; then
    # Image is bright, needs a dark theme for contrast
    echo "DARK"
else
    # Image is dark, needs a light theme for contrast
    echo "LIGHT"
fi

exit 0
