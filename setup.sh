#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting setup for niri dotfiles...."

# --- Preflight checks ---
echo "==> Check if os is 'Arch Linux'..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$NAME" != "Arch Linux" ] | [ "$NAME" != "CachyOS Linux" ]; then
        echo "Error: This script is only intended for $EXPECTED_OS."
        echo "Detected OS: $NAME"
        exit 1
    else
        echo "OS check passed: $NAME detected."
    fi
else
    echo "Warning: Cannot determine the OS using /etc/os-release."
    exit 1
fi

echo "==> Check if pacman is installed and up to date..."
if ! command -v pacman &> /dev/null; then
    echo "Error: 'pacman' is not installed or not in the PATH."
    echo "This script is intended for Arch Linux or Arch-based systems."
    exit 1
fi

echo "==> Make sure git is installed..."
sudo pacman -Syu --needed --noconfirm git base-devel fakeroot

# --- Configuration ---
# The location of the main dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The directory where stow will deploy the files (your home directory)
TARGET_DIR="$HOME"
# The directory where backups will be stored
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d-%H%M%S)"




# PLACEHOLDER echo "==> Clone dotfiles repository..."



# --- Package installation ---
echo "==> Installing required packages..."
# The files where the packages to install are configured
PKG_FILE="$DOTFILES_DIR/packages.txt"
AUR_FILE="$DOTFILES_DIR/aur-packages.txt"
# --- Pacman packages ---
if [[ -f "$PKG_FILE" ]]; then
    echo -e "\n📦 Installing packages from 'packages.txt'..."
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == \#* ]] && continue
        if ! pacman -Q "$pkg" &>/dev/null; then
            echo "  ➜ Installing $pkg..."
            sudo pacman -S --needed --noconfirm "$pkg"
        else
            echo "  ✓ $pkg already installed"
        fi
    done < "$PKG_FILE"
else
    echo "⚠️  No 'packages.txt' found, skipped."
fi

# --- Install paru if not installed ---
if ! command -v paru > /dev/null; then
    # Download the binary version to avoid compilation
    git clone https://aur.archlinux.org/paru-bin.git ~/repos/paru-bin
    cd ~/repos/paru-bin
    makepkg --syncdeps --install
    cd -
fi

# --- AUR packages ---
if [[ -f "$AUR_FILE" ]]; then
    echo -e "\n🌟 Installing AUR packages from 'aur-packages.txt'..."
    while IFS= read -r aurpkg; do
        [[ -z "$aurpkg" || "$aurpkg" == \#* ]] && continue
        if ! paru -Q "$aurpkg" &>/dev/null; then
            echo "  ➜ Installing $aurpkg..."
            paru -S --needed --noconfirm "$aurpkg"
        else
            echo "  ✓ $aurpkg already installed"
        fi
    done < "$AUR_FILE"
else
    echo "⚠️  No 'aur-packages.txt' found, skipped."
fi

# --- Enable Fish shell ---
if command -v fish >/dev/null 2>&1; then
    CURRENT_SHELL=$(basename "$SHELL")
    if [[ "$CURRENT_SHELL" != "fish" ]]; then
        echo "==> Enabling Fish shell..."
        if chsh -s "$(command -v fish)"; then
            echo "✅ Fish shell set successfully!"
        else
            echo "⚠️ Failed to change shell, please run 'chsh -s $(command -v fish)' manually."
        fi
    fi
fi

# --- Enable ly display manager ---
if command -v ly-dm >/dev/null 2>&1; then
    echo "==> Enabling ly display manager..."
    sudo systemctl enable ly.service
    echo "✅ ly enabled successfully!"
else
    echo "⚠️ ly not found, skipped enabling display manager."
fi

# --- Check stow ---
if ! command -v stow >/dev/null 2>&1; then
    echo "==> stow not found, installing..."
    sudo pacman -S --needed --noconfirm stow
fi

echo "==> Backup existing dotfiles and create symlinks with stow..."
echo "Dotfiles repository: $DOTFILES_DIR"
echo "Backup directory: $BACKUP_DIR"

# Create the main backup directory
mkdir -p "$BACKUP_DIR"
echo "Created backup directory: $BACKUP_DIR"

# Navigate into the dotfiles directory
cd "$DOTFILES_DIR"

# Loop through each package (directory) in the dotfiles repo
for package in */; do
    # Skip non-directory items or the script itself
    if [ ! -d "$package" ]; then
        continue
    fi

    echo "Processing package: $package"

    # Identify conflicts using stow's dry-run mode
    # --no: Perform dry run (no changes)
    # -v: Verbose output to capture conflict messages
    # -t: Target directory
    conflicts=$(stow -t "$TARGET_DIR" --no -v "$package" 2>&1 | awk '/\* existing target is neither a link nor a directory/ {print $NF}')

    if [ -n "$conflicts" ]; then
        echo "Found conflicts for $package. Backing up and resolving..."
        
        for conflict_path in $conflicts; do
            full_path="$TARGET_DIR/$conflict_path"
            
            # Ensure the parent directory for the backup path exists
            mkdir -p "$(dirname "$BACKUP_DIR/$conflict_path")"
            
            # Move the conflicting file/directory to the backup location
            if [ -e "$full_path" ]; then
                mv "$full_path" "$BACKUP_DIR/$conflict_path"
                echo "Moved existing '$full_path' to '$BACKUP_DIR/$conflict_path'"
                stow -R -t "$TARGET_DIR" $package --no-folding
            else
                echo "Warning: Conflict reported for '$full_path', but it doesn't exist. Skipping backup."
            fi
        done
    else
        echo "No conflicts found for $package during dry run."
        stow -R -t "$TARGET_DIR" $package --no-folding
    fi
done

echo "Backup and stow process finished successfully."

echo "==> Creating systemd user services..."
systemctl --user add-wants niri.service hypridle.service

echo "==> Done! 🎉"
