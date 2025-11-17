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
DOTFILES_DIR="$HOME/.dotfiles"
# The name of the specific 'package' folder within DOTFILES_DIR to stow
PACKAGE_NAME="dots-niri"
# The directory where stow will deploy the files (your home directory)
TARGET_DIR="$HOME"

# --- Backup current dotfiles ---
echo "==> Starting backup process..."
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d-%H%M%S)"
sudo pacman -Syu --needed --noconfirm rsync
echo "Targeting package: $PACKAGE_NAME"
echo "Backing up to: $BACKUP_DIR"

# Create the backup directory
mkdir -p "$BACKUP_DIR"
echo "Created backup directory $BACKUP_DIR"

# Navigate into the package directory where the source files are
cd "$DOTFILES_DIR/$PACKAGE_NAME"

# Iterate through all source files/directories
for item in .*; do
    # Skip standard directory entries
    if [ "$item" == "." ] || [ "$item" == ".." ] || [ "$item" == ".git" ] || [ "$item" == ".gitignore" ] || [ "$item" == ".stow-local-ignore" ] || [ "$item" == "setup.sh" ] || [ "$item" == "packages.txt" ] || [ "$item" == "aur-packages.txt" ]; then
        continue
    fi
    DEST_PATH="$TARGET_DIR/$item"
    
    # Check if *anything* exists at the destination path
    if [ -e "$DEST_PATH" ] || [ -L "$DEST_PATH" ]; then

        ORIGINAL_SOURCE=""
        # 1. Determine where the actual data lives
        if [ -L "$DEST_PATH" ]; then
            ORIGINAL_SOURCE=$(readlink -f "$DEST_PATH")
        else
            ORIGINAL_SOURCE="$DEST_PATH"
        fi

        # 2. ALWAYS back up the original data, regardless of where it is
        if [ -e "$ORIGINAL_SOURCE" ]; then
            echo "Found existing item: $DEST_PATH. Backing up the original content from $ORIGINAL_SOURCE..."
            # Ensure path structure is maintained in backup directory
            mkdir -p "$BACKUP_DIR/$(dirname "$item")"
            # Use rsync to copy the actual data into the backup directory
            rsync -a "$ORIGINAL_SOURCE" "$BACKUP_DIR/$item"
            echo "Copied data to $BACKUP_DIR/$item"
        else
            echo "Note: $DEST_PATH existed but its target $ORIGINAL_SOURCE did not (broken link?). Skipping data backup."
        fi

        # 3. Determine if the item needs to be REMOVED to make way for stow
        IS_MANAGED=false
        if [ -L "$DEST_PATH" ]; then
            # If it's a symlink pointing into our repo, it's managed, don't remove it.
            if [[ "$ORIGINAL_SOURCE" == "$DOTFILES_DIR"* ]]; then
                IS_MANAGED=true
            fi
        fi

        if [ "$IS_MANAGED" = true ]; then
            echo "Item $DEST_PATH is already managed by this repo (symlink points inward). Not removing it."
        else
            # If it's a real file/folder OR an unmanaged symlink, remove it.
            echo "Item $DEST_PATH is a conflict. Removing it to make way for stow."
            rm -rf "$DEST_PATH"
        fi

    else
        echo "No existing file/symlink found for $item. No conflict."
    fi
done
echo "✅ Backup phase complete."


# PLACEHOLDER echo "==> Clone dotfiles repository..."



# --- Package installation ---
echo "==> Installing required packages..."
# The files where the packages to install are configured
PKG_FILE="$DOTFILES_DIR/$PACKAGE_NAME/packages.txt"
AUR_FILE="$DOTFILES_DIR/$PACKAGE_NAME/aur-packages.txt"
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

echo "==> Creating symlinks with stow..."
# --- Run Stow ---
echo "Running stow for the '$PACKAGE_NAME' package..."

# Change directory to the parent of the dotfile package (where stow operates from)
cd "$DOTFILES_DIR"

# Run stow:
# -v: verbose output
# -t $HOME: sets the target directory to $HOME
stow -v -t "$HOME" "$PACKAGE_NAME"
echo "Stow process finished successfully."

echo "==> Creating systemd user services..."
systemctl --user add-wants niri.service hypridle.service

echo "==> Done! 🎉"
