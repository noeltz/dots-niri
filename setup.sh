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
    # Remove trailing slash from package name
    package_name=$(basename "$package")
    echo "Analyzing conflicts for package: $package_name"

    # Use find to list all potential targets in the package, then map them to actual $HOME paths
    # We strip the leading ./ from find's output
    conflicting_targets=""
    while IFS= read -r source_rel_path; do
        target_path="$TARGET_DIR/$source_rel_path"
        
        # Check if the target path exists (as a file, dir, or symlink) 
        # and is NOT already a symlink pointing back into our repo
        if [ -e "$target_path" ] || [ -L "$target_path" ]; then
            is_managed=false
            if [ -L "$target_path" ]; then
                # readlink -f gets the actual source path
                actual_source=$(readlink -f "$target_path")
                if [[ "$actual_source" == "$DOTFILES_DIR"* ]]; then
                    is_managed=true
                fi
            fi

            if [ "$is_managed" = false ]; then
                # This item is a conflict that needs backing up/removal
                conflicting_targets="$conflicting_targets $source_rel_path"
            fi
        fi

    done < <(find "$package_name" -printf "%P\n" | grep -v "^$" | grep -v "^\.")

    # Process conflicts if any were found
    if [ -n "$conflicting_targets" ]; then
        echo "Found actual conflicts for $package_name. Backing up and resolving..."
        
        for conflict_path in $conflicting_targets; do
            full_path="$TARGET_DIR/$conflict_path"
            
            # Ensure the backup directory structure is ready
            mkdir -p "$(dirname "$BACKUP_DIR/$conflict_path")"
            
            # Move the conflicting file/directory to the backup location
            if [ -e "$full_path" ] || [ -L "$full_path" ]; then
                mv "$full_path" "$BACKUP_DIR/$conflict_path"
                echo "Moved existing '$full_path' to '$BACKUP_DIR/$conflict_path'"
            fi
        done
    else
        echo "No unmanaged conflicts found for $package_name."
    fi
    echo "Stowing $package_name..."
    stow -R --no-folding -t "$TARGET_DIR" $package
done

echo "Backup and stow process finished successfully."

echo "==> Creating systemd user services..."
systemctl --user add-wants niri.service hypridle.service

echo "==> 
