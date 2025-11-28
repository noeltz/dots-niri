#!/bin/bash
#
# Luminance Theme Selector Script (Noeltz Edition) - Fixed Arithmetic
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
# The output might contain a decimal (e.g., 34000.4).
raw_output=$(/usr/bin/identify -format "%[mean]" "$image_path" 2>/dev/null)

if [ -z "$raw_output" ]; then
    echo "Error: Could not retrieve luminance data from ImageMagick. Is 'imagemagick' installed?" >&2
    exit 1
fi

# 2. **CRITICAL FIX**: Strip the decimal point and all subsequent characters
# using Bash parameter expansion. This converts '34000.4' to '34000' (integer).
raw_mean_luminance="${raw_output%.*}"

# Fallback in case stripping the decimal point failed or returned an empty string
if [ -z "$raw_mean_luminance" ] || ! [[ "$raw_mean_luminance" =~ ^[0-9]+$ ]]; then
    echo "Error: Failed to parse luminance value into an integer: '$raw_output'" >&2
    exit 1
fi

# 3. Normalize the raw mean (0-65535) to the 0-255 scale using Bash integer arithmetic.
# Bash integer division automatically truncates the result.
normalized_mean_luminance=$(( raw_mean_luminance / 256 ))

# 4. Decision Logic: Recommend DARK theme if the image is BRIGHT, and LIGHT if it is DARK.
if [ "$normalized_mean_luminance" -gt "$LUMINANCE_THRESHOLD" ]; then
    # Image is bright, needs a dark theme for contrast
    echo "DARK"
else
    # Image is dark, needs a light theme for contrast
    echo "LIGHT"
fi

exit 0
